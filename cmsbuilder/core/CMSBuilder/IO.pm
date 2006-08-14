# CMSBuilder © Леонов П. А., 2005-2006

# 
# Модуль управляет буферизацией вывода
# и определяет функции стандартных ошибок.
# 

package CMSBuilder::IO;
use strict qw(subs vars);
use utf8;

use Carp;
use POSIX 'strftime';
use CGI '-compile';

use Exporter;
our @ISA = 'Exporter';
our @EXPORT =
qw/
&err500 &err404 &err403 &errany
$sess %headers $system_ini $modules_ini
/;

use CMSBuilder::IO::Session;
use CMSBuilder::IO::Ini;
use CMSBuilder::IO::GUI;

use CMSBuilder::Utils;

our
(
	$mem,$out,%headers,
	$system_ini,$modules_ini,$sts,
	%errtext,%errstatus,$errtpl,
	$stdout_bkp,$err_catched
);

%errstatus =
(
	200 => 'OK',
	500 => 'Internal Server Error',
	404 => 'Not Found',
	403 => 'Forbidden',
	'*' => 'Unknown',
);

%errtext =
(
	500 => '<h4>На сервере произошла ошибка.</h4><p>Попробуйте обратиться к этой странице позже.</p>',
	404 => '<h4>Запрашиваемый документ не найден.</h4>',
	403 => '<h4>У вас нет доступа к этому разделу или элементу.</h4>
			<p>Если вы не вошли в систему под своим именем,<br> можете сделать это на <a href="'.$CMSBuilder::Config::http_aroot.'/login.ehtml"><u>странице входа в систему</u></a>.</p>',
	'*' => 'Неизвестная ошибка.'
);

#——————————————————————————— Рабочие функции интерфейса ————————————————————————

sub errany
{
	my $en = shift;
	my $etext = shift;
	
	$en =~ s/\D//g;
	
	$errtpl = $errtpl || f2var_utf8($CMSBuilder::Config::path_etc.'/errors.html.tpl');
	
	my $out = parsetpl
	(
		$errtpl,
		{
			errnum => $en,
			errtext => $etext || $errtext{$en} || $errtext{'*'},
			aroot => $CMSBuilder::Config::http_aroot,
		}
	);
	
	$headers{'Status'} = $en.' '.($errstatus{$en} || $errstatus{'*'});
	
	CMSBuilder::IO->send_data_utf8($out);
}

sub err500{ my $en = $err_catched = 500; errany($en); croak('Error '.$en.': '.join('',@_)); }
sub err404{ my $en = $err_catched = 404; errany($en); croak('Error '.$en.': '.join('',@_)); }
sub err403{ my $en = $err_catched = 403; errany($en); croak('Error '.$en.': '.join('',@_)); }

sub init
{
	# Заголовки
	%headers =
	(
		'Content-type' => 'text/html; charset=utf-8',
		'Pragma' => 'no-cache',
		'Cache-control' => 'max-age=0',
		'Expires' => '0',
		'X-Powered-By' => 'Paleo CMS Builder '.$CMSBuilder::version,
		'Last-Modified' => estrftime('%a, %d %b %Y %T %H:%M:%S GMT',localtime(time()-3600*2)),
	);
}

sub start
{
	my $c = shift;
	
	if($sts){ return; }
	$sts = 1;
	
	$c->init();
	
	select $stdout_bkp if $stdout_bkp;
	
	$system_ini = CMSBuilder::IO::Ini->new($CMSBuilder::Config::path_etc.'/system.ini');
	$modules_ini = CMSBuilder::IO::Ini->new($CMSBuilder::Config::path_etc.'/modules.ini');
	
	$out = 'вот он юникод';
	
	open($mem,'>:utf8',\$out);
	$stdout_bkp = select($mem);
	
	CMSBuilder::IO::Session->start();
}

sub sess { return \%CMSBuilder::IO::Session::sess; }

sub clear
{
	select $stdout_bkp if $stdout_bkp;
	close $mem;
	
	$out = 'снова юникод';
	open($mem,'>:utf8',\$out);
	
	select $mem;
}

sub stop
{
	my $c = shift;
	
	unless($sts){ return; }
	$sts = 0;
	
	CMSBuilder::IO::Session->stop();
	
	$system_ini = '';
	$modules_ini = '';
	
	select $stdout_bkp if $stdout_bkp;
	binmode(select(), ":utf8");
	close $mem;
	
	for my $flt (@CMSBuilder::Config::io_filters){ $flt->filt(\$out,\%headers); }
	
	$c->print_headers();
	print $out;
}

sub send_data_begin
{
	my $c = shift;
	
	select $stdout_bkp if $stdout_bkp;
	print_headers();
	binmode(select());
}

sub send_data_end
{
	my $c = shift;
	
	close(select(undef));
}

sub send_data
{
	my $c = shift;
	my $data = shift;
	
	$c->send_data_begin();
	binmode(select());
	print $data;
	$c->send_data_end();
}

sub send_data_utf8
{
	my $c = shift;
	my $data = shift;
	
	$c->send_data_begin();
	binmode(select(),':utf8');
	print $data;
	$c->send_data_end();
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


package CMSBuilder::IO::Filter;

sub filt {}

1;