#!/usr/bin/perl 

package main;

use DBI;
use CGI qw/param/;
use POSIX qw(strftime);



use strict qw(subs vars);
#use warnings;



my $out = '';
my $dir = '';
my $do_users = 0;

use vars '$print_error';
use vars '$buff';
use vars '$jlib';
use vars '$env_dir';
use vars '$dbo_dir';
use vars '$dbh';
use vars '$uid';
use vars '$gid';
use vars '@dbos';
use vars '@envs';



################################
@envs = ();
@dbos = ();
$dbh = '';
$print_error = 1;
$buff = 1;
$jlib = '../jlib';
$env_dir = $jlib.'/envs';
$dbo_dir = $jlib.'/dbo';
$uid = -1;
$gid = -1;
################################

sub mymain
{
	
	my(@parts,$i,$co,$str,$str_time,$jlogin,$rdir,$file);


	if($buff){
		open(MEM,'>',\$out);
		select(MEM);
	}	
	
	
	
	if($ENV{REDIRECT_STATUS} eq ""){ err404('REDIRECT_STATUS'); }
	
	$rdir  = $ENV{SCRIPT_FILENAME};
	$rdir =~ s/\/[^\/]+$/\//;
	chdir($rdir);
	
	require $jlib.'/jlogin.cgi';
	require $jlib.'/dbobject.cgi';
	require $jlib.'/dbarray.cgi';
	
	$file = $ENV{PATH_TRANSLATED};
	$file =~ s/\\/\//g;
	
	$dir = $file;
	$dir =~ s/\/[^\/]+$/\//;
	
	if($file eq ""){ err404('$ENV{PATH_TRANSLATED} - empty file name'); }
	
	

	if(!open(FILE, "< $file")){ err404('File not found: '.$file); }
	$str = join('',<FILE>);
	close(FILE);
	
	# Заголовки
	$str_time = strftime('%a, %d %b %Y %T %H:00:00 GMT',gmtime( time()+200 ));
	print "Content-type: text/html; charset=windows-1251\n";
	print "Pragma: no-cache\n";
	print "Last-Modified: $str_time\n";
	print "Expires: 0\n";
	print "\n";
	undef $str_time;


	$dbh = DBI->connect("DBI:mysql:engine", "root", "pas",{ RaiseError => 1 });
	$dbh->{HandleError} = sub {err505($_[0]);};

	if($do_users){
		$jlogin = JLogin::new($dbh);
		$uid = -1;
		$gid = -1;
		($uid,$gid) = $jlogin->verif();
		undef $jlogin;
	}else{
		$uid = 1; $gid = 0;
	}
	
	my $f;
	if(!opendir(CLS,$env_dir)){err505('Can`t open enveronments directory: '.$env_dir);}
	while($f = readdir(CLS)){
		if(! -f "$env_dir/$f"){next;}
		require "$env_dir/$f";
		#print "$env_dir/$f";
	
		$f =~ s/\.[^\.]*//;
	
		push @envs, $f;
	}
	closedir(CLS);



	$co = new CGI;
	
	for($i=0;$i<=$#envs;$i++){
	
		%{'EML::'.$envs[$i].'::cook'} = $co->cookie( 'EML_'.$envs[$i] );
		${'EML::'.$envs[$i].'::emlh'} = emlh($envs[$i]);
	}
	
	
	if(!opendir(DBO,$dbo_dir)){err505('Can`t open dbo directory: '.$dbo_dir);}
	while($file = readdir(DBO)){
		if(! -f "$dbo_dir/$file"){next;}
		require "$dbo_dir/$file";
		#print "$dbo_dir/$file";
	
		$file =~ s/\.[^\.]*//;
	
		push @dbos, $file;
	}
	closedir(DBO);
	undef $file;
	
	
	# Считываем и парсим конструкции <!--#include ... -->
	$str =~ s/<!--#include\s+(.+)\s+-->/SSI($1);/gei;
	
	# Считываем и парсим конструкции <?o object.method() ?>
	@parts = split(/<\?o(.+?)\?>/,$str);
	
	undef $str;
	
	for($i=0;$i<=$#parts;$i++){
	
		if($i % 2){ parse($parts[$i]) }
		else{ print $parts[$i]; }
	
	}
	
	undef $dbh;
	flush();

}


sub f2var
{
	my $f = shift;
	my $var;
	
	if(! open(SSI,'< '.$dir.$f) ){ return '[an error occurred while processing this directive]'; }
	$/ = \0;
	$var = <SSI>;
	$/ = "\n";
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


sub parse
{
	my $str = shift;
	my($body,$x,$type,$memb,$etc,$class,$ret);
	
	$str =~ s/\s//g;

	# Проверяем на наличие лишних символов
	if( $str =~ m/([^\w\.\,\-\_\(\)])/ ){err505("PARSE ERROR: Invalid character '$1' at \"<b>$str</b>\"");}
	
	# Делим на части класс.член.остальное
	($class,$memb,$etc) = split(/\./,$str,3);

	# Узнаём, что идёт после свойства.
	$memb =~ s/((\(.*\))*)$//;
	$type = $1;
	$type =~ s/\(|\)//g;
	
	# Если имя класса пусто - пишем ошибку
	if( $class eq "" ){err505("PARSE ERROR: Class name is empty at \"<b>$str</b>\"");}
	# Если нет файла с классом - пишем ошибку
	if( not -f "$env_dir/$class.cgi" ){err505("PARSE ERROR: Undefined class '$class' at \"<b>$str</b>\"");}

	
	# Проверяем наличие метода в классе
	if( !defined &{'EML::'.$class.'::'.$memb} ){err505("PARSE ERROR: Undefined method '$memb' at \"<b>$str</b>\"");}
	

	# Узнаём что страничка хочет передать методу
	my @pars = split(/\,/,$type);
	
	my @vals = ();
	
	# Получаем желаемое
	for(my $i=0;$i<=$#pars;$i++){ $vals[$i] = param($pars[$i]); }

	#my $p;		
	# Поступаем как PHP :)
	#for($p=0;$p<=$#pars;$p++){ ${''.$class.'::'.$pars[$p]} = $vals[$p]; }
		
	# Вызываем метод

	&{'EML::'.$class.'::'.$memb}(@vals);

	return '';

}

sub emlh
{

	return " onclick=\"return EML_href('$_[0]')\" ";

}

sub err404
{
	select(STDOUT);

	my $verr = "<br><h4><font color=red>$_[0]</font></h4><br>";
	if(!$print_error){$verr = ''}

	print <<"	END";
	Status: 404 Not Found
	Pragma: no-cache
	Expires: 0

<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>404 Not Found</TITLE>
</HEAD><BODY>
<H1>Not Found</H1>
The requested URL $ENV{REQUEST_URI} was not found on this server.<P>
<HR>
$ENV{SERVER_SIGNATURE}$verr
</BODY></HTML>
	END

	die('EML.CGI 404 ERROR: '.$_[0]);

}

sub err403
{
	select(STDOUT);

	my $verr = "<br><h4><font color=red>$_[0]</font></h4><br><a href='/login.ehtml'>Login...</a>";
	if(!$print_error){$verr = ''}

	print <<"	END";
	Status: 403 Access Denined
	Pragma: no-cache
	Expires: 0

<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>404 Access Denined</TITLE>
</HEAD><BODY>
<H1>Access Denined</H1>
The requested URL $ENV{REQUEST_URI} require authorisation! Login please.<P>
<HR>
$ENV{SERVER_SIGNATURE}$verr
</BODY></HTML>
	END

	die('EML.CGI 403 ERROR: '.$_[0]);

}

sub err505
{

	select(STDOUT);

	my $verr = "<br><h4><font color=red>$_[0]</font></h4><br>";
	if(!$print_error){$verr = ''}

	print <<"	END";
	Status: 505 Error
	Pragma: no-cache
	Expires: 0

<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>500 Internal Server Error</TITLE>
</HEAD><BODY>
<H1>Internal Server Error</H1>
The server encountered an internal error or
misconfiguration and was unable to complete
your request.<P>
Please contact the server administrator,
 pete\@nm.ru and inform them of the time the error occurred,
and anything you might have done that may have
caused the error.<P>
More information about this error may be available
in the server error log.<P>
<HR>
$ENV{SERVER_SIGNATURE}$verr
</BODY></HTML>
	END

	die('EML.CGI 505 ERROR: '.$_[0]);

}


sub send_cookie
{
	my %cookies;
	my $cook = '';
	my $i;
	my $co = new CGI;

	for($i=0;$i<=$#envs;$i++){

		%cookies = %{''.$envs[$i].'::cook'};

		$cook = $co->cookie(
			-name=>'EML_'.$envs[$i],
			-value=>\%cookies,
			-path=>'/',
			-expires=>'+30d'
		);

		print 'Set-Cookie: ',$cook->as_string,"\n";

	}
}

sub flush
{
	if(!$buff){return;}

	$buff = 0;
	select(STDOUT);
	close MEM;

	send_cookie();

	$out =~ s/\n/\r\n/g;
	print $out;
	$out = '';
}

sub unflush
{
	if(!$buff){return;}

	$buff = 0;
	select(STDOUT);
	close MEM;

	$out = '';
}

#main::err403(3);
mymain();

print 'Done OK';



