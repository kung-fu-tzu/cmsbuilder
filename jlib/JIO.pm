# (с) Леонов П.А., 2005

# 
# Модуль управляет буферизацией вывода
# и определяет функции стандартных ошибок.
# 

package JIO;
use strict qw(subs vars);
use Exporter;
use Carp;
use JIO::Session;
use JIO::Ini;
use JIO::Users;
use POSIX ('strftime');

our @EXPORT = ('err505','err404','err403','err402','sess');
our @ISA = 'Exporter';

our %headers;
our $out;
our $cgi;
our $system_ini;
our $modules_ini;
our $sts;

local *MEM;


###################################################################################################
# Рабочие функции интерфейса
###################################################################################################

sub errany
{
	my $en = shift;
	clear();
	$JIO::headers{'Location'} = $JConfig::http_errors.'/err'.$en.($en==402?'.ehtml':'.html');
	stop();
	croak 'Error '.$en.': '.join('',@_);
}

sub err505{ errany(505,@_); }
sub err404{ errany(404,@_); }
sub err403{ errany(403,@_); }
sub err402{ errany(402,@_); }

sub start
{
	if($sts){ return; }
	$sts = 1;
	
	$system_ini = JIO::Ini->new($JConfig::path_etc.'/system.ini');
	$modules_ini = JIO::Ini->new($JConfig::path_etc.'/modules.ini');
	
	if($JConfig::buff_do)
	{
		if($JConfig::buff_mem)
		{
			open(MEM,'>',\$out);
		}
		else
		{
			open(MEM,'>'.$JConfig::path_tmp.'/out'.$$.'.tmp');
		}
		
		select(MEM);
	}
	
	# Заголовки
	my $str_time = strftime('%a, %d %b %Y %T %H:00:00 GMT',gmtime( time()+200 ));
	
	%headers =
	(
		'Content-type' => 'text/html; charset=windows-1251',
		'Pragma' => 'no-cache',
		'Cache-control' => 'max-age=0',
		'Expires' => '0',
		'Last-Modified' => $str_time
	);
	
	$out = '';
	
	$cgi = CGI->new();
	
	JIO::Session->start();
	
	print "\n\n";
	
	JIO::Users->init();
}

sub sess { return \%JIO::Session::sess; }

sub clear
{
	if($JConfig::buff_do)
	{
		select STDOUT;
		close MEM;
		
		if($JConfig::buff_mem)
		{
			$out = '';
			open(MEM,'>',\$out);
		}
		else
		{
			open(MEM,'>out'.$$.'.tmp');
		}
		
		select MEM;
	}
}

sub stop
{
	unless($sts){ return; }
	$sts = 0;
	
	JIO::Users->clear();
	JIO::Session->stop();
	
	$system_ini = '';
	$modules_ini = '';
	
	if($JConfig::buff_do)
	{
		select(STDOUT);
		close MEM;
		
		unless($JConfig::buff_mem)
		{
			open(MEM,'<'.$JConfig::path_tmp.'/out'.$$.'.tmp');
			$out = join('',<MEM>);
			close MEM;
			
			unlink($JConfig::path_tmp.'/out'.$$.'.tmp');
		}
		
		#$out =~ s/\n/\r\n/g;
		print_headers();
		print $out;
	}
}

sub closeio
{
	close(select());
}

sub print_headers
{
	my $hdr;
	for $hdr (keys %headers)
	{
		print $hdr,': ',$headers{$hdr},"\n";
	}
	print "\n";
}

1;