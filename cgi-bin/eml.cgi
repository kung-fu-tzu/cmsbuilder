#!/usr/bin/perl

# ������ ������ ���������� � PATH ����.
# ���� � �� ����������� ���� <?o ... ?>
# ��������� ���������� ����������� � ������� ����������
# �������� Perl.
# ������� ��������� � ���� �������

package main;

# ����� ������� #######

$eml::print_error = 1;
$eml::DBI = 1;
$eml::USR = 1;
$eml::buff = 1;
$eml::jlib = '../jlib';
$eml::env_dir = $eml::jlib.'/envs';
$eml::dbo_dir = $eml::jlib.'/dbo';

#######################


# ���������� ������� ##

@eml::envs = ();
@eml::dbos = ();
$eml::out = '';
#*MEM;
if($eml::buff){
	open(MEM,'>',\$eml::out);
	select(MEM);
}

#######################

use CGI qw/param/;
use POSIX qw(strftime);

if($eml::DBI){use DBI;}


# ���� ������ �������� - �����.
if($ENV{REDIRECT_STATUS} eq ""){ err404('REDIRECT_STATUS'); }

$eml::rdir = $ENV{SCRIPT_FILENAME};
$eml::file =~ s/\\/\//g;
$eml::rdir =~ s/\/[^\/]+$/\//;
chdir($eml::rdir);


#$eml::root = $ENV{DOCUMENT_ROOT};
$eml::file = $ENV{PATH_TRANSLATED};
$eml::file =~ s/\\/\//g;

$eml::dir = $eml::file;
$eml::dir =~ s/\/[^\/]+$/\//;


# ���� ������ - �����.
if($eml::file eq ""){ err404('$ENV{PATH_TRANSLATED} - empty file name'); }

# ���� �� � ���������� htdocs - ����, �����.
#if($eml::file !~ /^$eml::root/){ err404('File name out of DOCUMENT_ROOT: '.$eml::file); }

# ���� ������ ����� ���, ���������� ����������� ������.
if(!open(FILE, "< $eml::file")){ err404('File not found: '.$eml::file); }
$/ = \0;
my $str = <FILE>;
$/ = "\n";
close(FILE);


# ���������
my $str_time = strftime('%a, %d %b %Y %T %H:00:00 GMT',gmtime( time()+200 ));
print "Content-type: text/html; charset=windows-1251\n";
print "Pragma: no-cache\n";
print "Last-Modified: $str_time\n";
print "Expires: 0\n";
print "\n";
undef $str_time;

if($eml::DBI){
	use DBI;
	# ���������� � ���� ������
	$dbh = DBI->connect("DBI:mysql:engine", "root", "pas",{ RaiseError => 1 });
	$dbh->{HandleError} = sub {err505($_[0]);};
}

if($eml::USR){
	# �������� ��. ������������ �� ������ �������������� :)
	require $eml::jlib.'/jlogin.cgi';
	$jlogin = JLogin::new($dbh);
	$uid = 0;
	$gid = 0;
	($uid,$gid) = $jlogin->verif();
}
else{ $uid = 1; $gid = 0; }

if($uid > 0 and $gid == 0){ $eml::print_error = 1 }else{ $eml::print_error = 0 };

# ������ ����� ������
$co = new CGI;


my $file;
if(!opendir(CLS,$eml::env_dir)){err505('Can`t open enveronments directory: '.$eml::env_dir);}
while($file = readdir(CLS)){
	if(! -f "$eml::env_dir/$file"){next;}
	require "$eml::env_dir/$file";

	$file =~ s/\.[^\.]*//;

	push @eml::envs, $file;
}
closedir(CLS);

for(my $i=0;$i<=$#eml::envs;$i++){

	%{'EML::'.$eml::envs[$i].'::cook'} = $co->cookie( 'EML_'.$eml::envs[$i] );
	${'EML::'.$eml::envs[$i].'::emlh'} = emlh($eml::envs[$i]);
}


require $eml::jlib.'/dbobject.cgi';
require $eml::jlib.'/dbarray.cgi';
if(!opendir(DBO,$eml::dbo_dir)){err505('Can`t open dbo directory: '.$eml::dbo_dir);}
while($file = readdir(DBO)){
	if(! -f "$eml::dbo_dir/$file"){next;}
	require "$eml::dbo_dir/$file";

	$file =~ s/\.[^\.]*//;

	push @eml::dbos, $file;
}
closedir(DBO);
undef $file;

# ��������� � ������ ����������� <!--#include ... -->
$str =~ s/<!--#include\s+(.+)\s+-->/SSI($1);/gei;

# ��������� � ������ ����������� <?o object.method() ?>
@eml::parts = split(/<\?o(.+?)\?>/,$str);

undef $str;

for(my $i=0;$i<=$#eml::parts;$i++){

	if($i % 2){ parse($eml::parts[$i]) }
	else{ print $eml::parts[$i]; }

}

sub f2var
{
	my $f = shift;
	my $var;
	
	if(! open(SSI,'< '.$eml::dir.$f) ){ return '[an error occurred while processing this directive]'; }
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

	# ��������� �� ������� ������ ��������
	if( $str =~ m/([^\w\.\,\-\_\(\)])/ ){err505("PARSE ERROR: Invalid character '$1' at \"<b>$str</b>\"");}
	
	# ����� �� ����� �����.����.���������
	($class,$memb,$etc) = split(/\./,$str,3);

	# �����, ��� ��� ����� ��������.
	$memb =~ s/((\(.*\))*)$//;
	$type = $1;
	$type =~ s/\(|\)//g;
	
	# ���� ��� ������ ����� - ����� ������
	if( $class eq "" ){err505("PARSE ERROR: Class name is empty at \"<b>$str</b>\"");}
	# ���� ��� ����� � ������� - ����� ������
	if( not -f "$eml::env_dir/$class.cgi" ){err505("PARSE ERROR: Undefined class '$class' at \"<b>$str</b>\"");}

	
	# ��������� ������� ������ � ������
	if( !defined &{'EML::'.$class.'::'.$memb} ){err505("PARSE ERROR: Undefined method '$memb' at \"<b>$str</b>\"");}
	

	# ����� ��� ��������� ����� �������� ������
	my @pars = split(/\,/,$type);
	
	my @vals = ();
	
	# �������� ��������
	for(my $i=0;$i<=$#pars;$i++){ $vals[$i] = param($pars[$i]); }

	#my $p;		
	# ��������� ��� PHP :)
	#for($p=0;$p<=$#pars;$p++){ ${'EML::'.$class.'::'.$pars[$p]} = $vals[$p]; }
		
	# �������� �����
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
	if(!$eml::print_error){$verr = ''}

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
	if(!$eml::print_error){$verr = ''}

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
	if(!$eml::print_error){$verr = ''}

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
 pete@nm.ru and inform them of the time the error occurred,
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


sub EML::send_cookie
{
	my %cookies;
	my $cook = '';

	for($i=0;$i<=$#eml::envs;$i++){

		%cookies = %{'EML::'.$eml::envs[$i].'::cook'};

		$cook = $co->cookie(
			-name=>'EML_'.$eml::envs[$i],
			-value=>\%cookies,
			-path=>'/',
			-expires=>'+30d'
		);

		print 'Set-Cookie: ',$cook->as_string,"\n";

	}
}

sub EML::flush
{
	if(!$eml::buff){return;}

	$eml::buff = 0;
	select(STDOUT);
	close MEM;

	EML::send_cookie();

	$eml::out =~ s/\n/\r\n/g;
	print $eml::out;
}

sub EML::unflush
{
	if(!$eml::buff){return;}

	$eml::buff = 0;
	select(STDOUT);
	close MEM;

	$eml::out = '';
}

# ���� ������ ���������� ��������� - �� �����.
# ������� �����.

EML::flush();


