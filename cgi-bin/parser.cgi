#!/usr/bin/perl

# Скрипт парсит переданный в PATH файл.
# Ищет в нём конструкции типа <?o ... ?>
# Разбирает содержимое конструкции и передаёт управление
# функциям Perl.
# Функции выполнены в виде пакетов

use DBI;
use CGI qw/param/;

# Если вызван напрямую - отбой.
if($ENV{REDIRECT_STATUS} eq ""){
	print "Content-type: text/html\n\n";
	print "Redirect status.";
	exit();
}

$phtml::root = $ENV{DOCUMENT_ROOT};

$phtml::file = $ENV{PATH_TRANSLATED};

# Строчка для винды :)
$phtml::file =~ s/\\/\//g;

# Если пустой - отбой.
if($phtml::file eq ""){
	print "Content-type: text/html\n\n";
	print "Empty.";
	exit();
}

# Если не в директории htdocs - тоже, отбой.
if($phtml::file !~ /^$phtml::root/){
	print "Content-type: text/html\n\n";
	print "Wrong path.";
	exit();
}

# Если такого файла нет, изображаем стандартную ошибку.
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

# Заголовки
print "Content-type: text/html\n";
print "Pragma: no-cache\n";
print "Expires: 0\n";
print "\n";

# Конектимся к базе данных
$dbh = DBI->connect("DBI:mysql:engine", "root", "pas",{ RaiseError => 1 });
$dbh->{HandleError} = sub {print "<h5><font color=red>$_[0]</font></h5>"; die($_[0]);};

# Получаем ид. пользователя от модуля аутентификации :)
require '../lib/jlogin.cgi';
$jlogin = JLogin::new($dbh);
$uid = 0;
$uid = $jlogin->verif();

# Подгружаем функции для работы со связанными объектами (объект-ечейка_базы)
require '../lib/etablesfuncs.cgi';

my $file;
if(!opendir(CLS,'../lib/classes')){print 'Error';}
while($file = readdir(CLS)){
	if(! -f "../lib/classes/$file"){next;}
	require "../lib/classes/$file";
}
closedir(CLS);

# Создаём кукис объект
$co = new CGI;

# Считываем и парсим конструкции <?o object.method() ?>
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
	
	# Проверяем на наличие лишних символов
	if( $str =~ m/([^\w\.\,\-\_\(\)])/ ){return "PARSE ERROR: Invalid character '$1' at \"<b>$str</b>\"";}
	
	# Делим на части класс.член.остальное
	($class,$memb,$etc) = split(/\./,$str,3);

	# Если указано только имя класса, то свойство приравниваем 'default'
	if($memb eq ""){$memb = "default"}

	# Узнаём, что идёт после свойства.
	$memb =~ s/((\(.*\))*)$//;
	$type = $1;
	
	# Если имя класса пусто - пишем ошибку
	if( $class eq "" ){return "PARSE ERROR: Class name is empty at \"<b>$str</b>\"";}
	# Если нет файла с классом - пишем ошибку
	if( not -f "../lib/ocls/$class.cgi" ){return "PARSE ERROR: Undefined class '$class' at \"<b>$str</b>\"";}
	
	# !!!!!!!!!!!!!!!
	if( ! require "../lib/ocls/$class.cgi" ){return "PARSE ERROR: Require return false at \"<b>$str</b>\"";}
	
	
	if($type eq ''){# Тип - свойство
		# Проверяем наличие св-ва в классе
		if( !defined ${'OML::'.$class.'::'.$memb} ){return "PARSE ERROR: Undefined property '$memb' at \"<b>$str</b>\"";}
		return ${$class.'::'.$memb};
	}elsif($type =~ /\(/){# Тип - мотод
	
		# Проверяем наличие метода в классе
		if( !defined &{'OML::'.$class.'::'.$memb} ){return "PARSE ERROR: Undefined method '$memb' at \"<b>$str</b>\"";}
	
		$type =~ s/^\(//;
		$type =~ s/\)$//;
		# Узнаём что страничка хочет передать методу
		my @pars = split(/\,/,$type);
	
		my @vals = ();
	
		# Получаем желаемое
		for(my $i=0;$i<=$#pars;$i++){ $vals[$i] = param($pars[$i]); }
	
		# Получаем куки для данного класса
		my %cook = $co->cookie( 'OML_'.$class );
	
		# Устанавливаем куки
		%{'OML::'.$class.'::cook'} = %cook;
		
		my $p;
		
		# Поступаем как PHP :)
		#for($p=0;$p<=$#pars;$p++){ ${'OML::'.$class.'::'.$pars[$p]} = $vals[$p]; }
		
		# Вызываем метод
		&{'OML::'.$class.'::'.$memb}(@vals); #@vals
		# Получаем результат
		$ret = ${'OML::'.$class.'::rets'};
		# Обнуляем буфер
		${'OML::'.$class.'::rets'} = '';
		# Возвращаем результат парсеру
		return $ret;
	}else{# Неизвестный тип
		return "PARSE ERROR: Undefined member type '$type' at \"<b>$str</b>\"";
	}
	
	return 'OK';
}



sub omlh
{

	return " onclick=\"return OML_href('$_[0]')\" ";

}










