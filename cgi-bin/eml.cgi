#!/usr/bin/perl

package eml;

use DBI;
use CGI ('param');
use POSIX ('strftime');


use strict qw(subs vars);
#use warnings;



my $out = '';
my $dir = '';
my $ruid = '';
my $rgid = '';

use vars '$print_error';
use vars '$buff';
use vars '$jlib';
use vars '$env_dir';
use vars '$dbo_dir';
use vars '$sess_dir';
use vars '$dbh';
use vars '$path';
use vars '$cgi';
use vars '@dbos';
use vars '@envs';
use vars '%sess';
use vars '$do_users';
use vars '$files_dir';
use vars '%opts';

use vars '$uid';
use vars '$gid';
use vars '$g_user';
use vars '$g_group';
use vars '%dbo_cache';

sub mymain
{
	################################
	
	$jlib = '../jlib';
	$env_dir = $jlib.'/packages';
	$dbo_dir = $jlib.'/classes';
	$sess_dir = $jlib.'/etc/sessions';
	
	$files_dir = '../htdocs/files/';
	
	%opts = ();
	dbmopen(%opts,$jlib.'/etc/options',0640) or die 'OPTIONS_NOT_OPEN';
	
	################################
	
	# ��������� #

	%dbo_cache = ();
	$do_users = 0;
	$print_error = 1;
	$buff = 1;
	
	$g_user = '';
	@envs = ();
	@dbos = ();
	$dbh = '';
	
	$uid = -1;
	$gid = -1;
	$ruid = -1;
	$rgid = -1;
	
	$out = '';
	$dir = '';
	
	$cgi = new CGI;

	#############
	
	my(@parts,$i,$co,$str,$str_time,$jlogin,$rdir,$file);

	if($ENV{'REDIRECT_STATUS'} eq ""){ die('REDIRECT_STATUS'); }
	
	
	$rdir  = $ENV{'SCRIPT_FILENAME'};
	$rdir =~ s/\/[^\/]+$/\//;
	chdir($rdir);
	require $jlib.'/errors.cgi';
	
	
	require $jlib.'/jlogin.cgi';
	require $jlib.'/jsession.cgi';
	require $jlib.'/dbobject.cgi';
	require $jlib.'/dbarray.cgi';
	require $jlib.'/htmlfilter.cgi';
	
	%sess = ();
	JSession::start();
	
	$file = $ENV{'PATH_TRANSLATED'};
	$file =~ s/\\/\//g;
	
	$file =~ s/\.ehtml(\/.*)//;
	$path = $1;
	if($path){ $file .= '.ehtml'; }
	
	$dir = $file;
	$dir =~ s/\/[^\/]+$/\//;
	
	if($file eq ""){ err404($ENV{'PATH_TRANSLATED'}.' - empty file name'); }
	
	if($buff){
		#open(MEM,'>',\$out);
		open(MEM,'>out'.$$.'.tmp');
		select(MEM);
	}	
	
	if(!open(FILE, "< $file")){ err404('File not found: '.$file); }
	$str = join('',<FILE>);
	close(FILE);
	
	# ���������
	$str_time = strftime('%a, %d %b %Y %T %H:00:00 GMT',gmtime( time()+200 ));
	print "Content-type: text/html; charset=windows-1251\n";
	print "Pragma: no-cache\n";
	print "Last-Modified: $str_time\n";
	print "Expires: 0\n";
	print "\n";
	undef $str_time;
	
	
	require 'mysql_cfg.cgi'; 
	$dbh = DBI->connect(ret_mysql(),{ RaiseError => 1 });
	$dbh->{'HandleError'} = sub {err505($_[0]);};
	
	my $f;
	if(!opendir(CLS,$env_dir)){err505('Can`t open enveronments directory: '.$env_dir);}
	while($f = readdir(CLS)){
		if(! -f "$env_dir/$f"){next;}
		require "$env_dir/$f";
		
		$f =~ s/\.[^\.]*//;
		push @envs, $f;
	}
	closedir(CLS);
	
	
	if(!opendir(DBO,$dbo_dir)){err505('Can`t open dbo directory: '.$dbo_dir);}
	while($file = readdir(DBO)){
		if(! -f "$dbo_dir/$file"){next;}
		require "$dbo_dir/$file";
		
		$file =~ s/\.[^\.]*//;
		push @dbos, $file;
	}
	closedir(DBO);
	undef $file;
	
	
	if($do_users){
		($g_user,$g_group) = JLogin::verif();
		$g_user  = $g_user?$g_user->no_cache():undef;
		$g_group = $g_group?$g_group->no_cache():undef;
		
		$g_user->{'_temp_object'} = 1;
		$g_group->{'_temp_object'} = 1;
		
		$uid = $g_user->{'ID'};
		$gid = $g_group->{'ID'};
	}else{
		$g_user = User::new();
		$g_group = UserGroup::new();
		
		$g_user = $g_user->no_cache();
		$g_group = $g_group->no_cache();
		
		$g_user->{'name'} = '����������� �����';
		$g_group->{'cms'} = 1;
		$g_group->{'html'} = 1;
		$g_group->{'root'} = 1;
		$g_user->{'_temp_object'} = 1;
		$g_group->{'_temp_object'} = 1;
		
		$uid = 1; $gid = 1;
	}
	
	
	# ��������� � ������ ����������� <!--#include ... -->
	$str =~ s/<!--#include\s+(.+)\s+-->/SSI($1);/gei;
	
	# ��������� � ������ ����������� <?eml package::sub() ?>
	@parts = split(/<\?eml((?:.|\n)+?)\?>/,$str);
	
	undef $str;
	
	for($i=0;$i<=$#parts;$i++){
		
		if($i % 2){ eval($parts[$i]); if($@){ err505('eval("'.$parts[$i].'")') } }
		else{ print $parts[$i]; }
	}
	
	#print '<b> JLogin_sid = ',$sess{'JLogin_sid'},'</b>';
	
	flush();
	%dbo_cache = ();
	undef $dbh;
	
	dbmclose(%opts);
}

sub f2var
{
	my $f = shift;
	my $var;
	
	if(! open(SSI,'< '.$dir.$f) ){ return '[an error occurred while processing this directive]'; }
	$var = join('',<SSI>);
	close(SSI);
	
	return $var;
}

sub SSI
{
	my $str = shift;
	my $ret = '';
	
	if($str =~ m/\w+="(.+?)"/){ $ret = f2var($1); }
	
	return $ret;
}

sub flush
{
	if(!$buff){return;}
	
	JSession::stop();
	
	$buff = 0;
	select(STDOUT);
	close MEM;
	
	open(MEM,'<out'.$$.'.tmp');
	$out = join('',<MEM>);
	close MEM;
	
	unlink('out'.$$.'.tmp');
	
	$out =~ s/\n/\r\n/g;
	print $out;
	$out = '';
}

sub unflush
{
	JSession::stop();
	
	if(!$buff){return;}
	
	$buff = 0;
	select(STDOUT);
	close MEM;
	unlink('out'.$$.'.tmp');
	
	$out = '';
}

sub classOK
{
	my $cn = shift;
	my $i = '';
	
	for $i (@eml::dbos){ if($i eq $cn ){ return 1; } }
	
	return 0;
}

mymain();

#print 'END OK';

