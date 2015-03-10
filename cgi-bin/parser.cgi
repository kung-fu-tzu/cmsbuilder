#!/usr/bin/perl

# ������ ������ ���������� � PATH ����.
# ���� � �� ����������� ���� <?o ... ?>
# ��������� ���������� ����������� � ������� ����������
# �������� Perl.
# ������� ��������� � ���� �������

use DBI;
use CGI qw/param/;

# ���� ������ �������� - �����.
if($ENV{REDIRECT_STATUS} eq ""){
	print "Content-type: text/html\n\n";
	print "Redirect status.";
	exit();
}

$phtml::root = $ENV{DOCUMENT_ROOT};

$phtml::file = $ENV{PATH_TRANSLATED};

# ������� ��� ����� :)
$phtml::file =~ s/\\/\//g;

# ���� ������ - �����.
if($phtml::file eq ""){
	print "Content-type: text/html\n\n";
	print "Empty.";
	exit();
}

# ���� �� � ���������� htdocs - ����, �����.
if($phtml::file !~ /^$phtml::root/){
	print "Content-type: text/html\n\n";
	print "Wrong path.";
	exit();
}

# ���� ������ ����� ���, ���������� ����������� ������.
if(not open(FILE, "< $phtml::file")){
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
	$ENV{SERVER_SIGNATURE}
	</BODY></HTML>
	END

	exit();
}

# ���������
print "Content-type: text/html\n";
print "Pragma: no-cache\n";
print "Expires: 0\n";
print "\n";

# ���������� � ���� ������
$dbh = DBI->connect("DBI:mysql:engine", "root", "pas",{ RaiseError => 1 });
$dbh->{HandleError} = sub {print "<h5><font color=red>$_[0]</font></h5>"; die($_[0]);};

# �������� ��. ������������ �� ������ �������������� :)
require '../lib/jlogin.cgi';
$jlogin = JLogin::new($dbh);
$uid = 0;
$uid = $jlogin->verif();

# ���������� ������� ��� ������ �� ���������� ��������� (������-������_����)
require '../lib/etablesfuncs.cgi';

my $file;
if(!opendir(CLS,'../lib/classes')){print 'Error';}
while($file = readdir(CLS)){
	if(! -f "../lib/classes/$file"){next;}
	require "../lib/classes/$file";
}
closedir(CLS);

# ������ ����� ������
$co = new CGI;

# ��������� � ������ ����������� <?o object.method() ?>
$str = join('',<FILE>);
$str =~ s/<\?o *([^\?]+?) *\?>/parse($1)/ge;

print $str;



sub preparse
{
	my $str = shift;
	my @arr = split(/\s+/,$str);
	my @ret;

	for(my $i=0;$i<=$#arr;$i++){

		$ret[$i] = parse($arr[$i]);
	}



	return join(" ",@ret);

}

sub parse
{
	$str = shift;
	my($body,$x,$type,$memb,$etc,$class,$ret);
	
	# ��������� �� ������� ������ ��������
	if( $str =~ m/([^\w\.\,\-\_\(\)])/ ){return "PARSE ERROR: Invalid character '$1' at \"<b>$str</b>\"";}
	
	# ����� �� ����� �����.����.���������
	($class,$memb,$etc) = split(/\./,$str,3);

	# ���� ������� ������ ��� ������, �� �������� ������������ 'default'
	if($memb eq ""){$memb = "default"}

	# �����, ��� ��� ����� ��������.
	$memb =~ s/((\(.*\))*)$//;
	$type = $1;
	
	# ���� ��� ������ ����� - ����� ������
	if( $class eq "" ){return "PARSE ERROR: Class name is empty at \"<b>$str</b>\"";}
	# ���� ��� ����� � ������� - ����� ������
	if( not -f "../lib/ocls/$class.cgi" ){return "PARSE ERROR: Undefined class '$class' at \"<b>$str</b>\"";}
	
	# !!!!!!!!!!!!!!!
	if( ! require "../lib/ocls/$class.cgi" ){return "PARSE ERROR: Require return false at \"<b>$str</b>\"";}
	
	
	if($type eq ''){# ��� - ��������
		# ��������� ������� ��-�� � ������
		if( !defined ${'OML::'.$class.'::'.$memb} ){return "PARSE ERROR: Undefined property '$memb' at \"<b>$str</b>\"";}
		return ${$class.'::'.$memb};
	}elsif($type =~ /\(/){# ��� - �����
	
		# ��������� ������� ������ � ������
		if( !defined &{'OML::'.$class.'::'.$memb} ){return "PARSE ERROR: Undefined method '$memb' at \"<b>$str</b>\"";}
	
		$type =~ s/^\(//;
		$type =~ s/\)$//;
		# ����� ��� ��������� ����� �������� ������
		my @pars = split(/\,/,$type);
	
		my @vals = ();
	
		# �������� ��������
		for(my $i=0;$i<=$#pars;$i++){ $vals[$i] = param($pars[$i]); }
	
		# �������� ���� ��� ������� ������
		my %cook = $co->cookie( 'OML_'.$class );
	
		# ������������� ����
		%{'OML::'.$class.'::cook'} = %cook;
		
		my $p;
		
		# ��������� ��� PHP :)
		#for($p=0;$p<=$#pars;$p++){ ${'OML::'.$class.'::'.$pars[$p]} = $vals[$p]; }
		
		# �������� �����
		&{'OML::'.$class.'::'.$memb}(@vals); #@vals
		# �������� ���������
		$ret = ${'OML::'.$class.'::rets'};
		# �������� �����
		${'OML::'.$class.'::rets'} = '';
		# ���������� ��������� �������
		return $ret;
	}else{# ����������� ���
		return "PARSE ERROR: Undefined member type '$type' at \"<b>$str</b>\"";
	}
	
	return 'OK';
}



sub omlh
{

	return " onclick=\"return OML_href('$_[0]')\" ";

}










