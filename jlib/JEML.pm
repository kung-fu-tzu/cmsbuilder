package JEML;
use strict qw(subs vars);

use JIO;
use JIO::Session;
use CGI 'param';

###################################################################################################
# Ѕазовые переменные интерфейса
###################################################################################################

our(@head,$dir,@pull,$path,%sess,$part_num);

sub init
{
	@head = ();
	$dir = '';
	@pull = ();
	
	$path = '';
	%sess = ();
}

sub doall
{
	my $cn = shift;
	my $eml = $cn->new();

	$eml->init_normal();
	
	$eml->parse();
	$eml->construct();
	$eml->execute();
	
	return $eml;
}

sub new
{
	my $class = shift;
	
	my $o = {};
	bless($o,$class);
	
	return $o;
}

sub parser { return $pull[$#pull]; }

sub header
{
	my $str = shift;
	
	unless($str){ return join('',@head); }
	
	push(@head, $str);
}

sub parse
{
	my $o = shift;
	local *EMLFILE;
	
	if(!open(EMLFILE, '< '.$o->{'file'})){ JIO::err404('File not found: '.$o->{'file'}); }
	$o->{'data'} = join('',<EMLFILE>);
	close(EMLFILE);
	
	# —читываем и парсим конструкции <!--#include ... -->
	chdir($o->{'dir'});
	$o->{'data'} =~ s/<!--#include\s+(.+)\s+-->/SSI($o,$1);/gei;
	chdir($o->{'cgi_dir'});
	
	# —читываем и парсим конструкции <?eml *** ?>
	$o->{'parts'} = [ split(/<\?eml((?:.|\n)+?)\?>/,$o->{'data'}) ];
}

sub execute
{
	my $o = shift;
	
	push @pull, $o;
	eval($o->{'code'});
	pop @pull;
	
	if($@){ JIO::err505($@,'eval("'.$o->{'parts'}[$part_num].'") in '.$o->{'file'}) };
}

sub construct
{
	my $o = shift;
	my $i;
	$o->{'parts'}[$#{ $o->{'parts'} }+1] = '';
	for($i=0;$i<=$#{ $o->{'parts'} };$i+=2){
		$o->{'code'} .= 'print parser()->{\'parts\'}['.$i.']; $JEML::part_num = '.($i+1).'; '.$o->{'parts'}[$i+1].';';
	}
}

sub init_normal
{
	my $o = shift;
	
	unless($ENV{'REDIRECT_STATUS'}){ die('REDIRECT_STATUS'); }
	
	$o->{'cgi_dir'} = $ENV{'SCRIPT_FILENAME'};
	$o->{'cgi_dir'} =~ s/\/[^\/]+$/\//;
	
	$o->{'file'} = $ENV{'PATH_TRANSLATED'};
	$o->{'file'} =~ s/\\/\//g;
	
	$o->{'file'} =~ s/\.ehtml(\/.*)//;
	$o->{'path'} = $1;
	if($o->{'path'}){ $o->{'file'} .= '.ehtml'; }
	
	$o->{'dir'} = $o->{'file'};
	$o->{'dir'} =~ s/\/[^\/]+$/\//;
	
	unless($o->{'file'}){ JIO::err404($ENV{'PATH_TRANSLATED'}.' - empty file name'); }
}

sub f2var
{
	my $o = shift;
	my $f = shift;
	my $var;
	local *SSI;
	
	unless( open(SSI,'< '.$f) ){ return '[an error occurred while processing this directive]'; }
	$var = join('',<SSI>);
	close(SSI);
	
	return $var;
}

sub SSI
{
	my $o = shift;
	my $str = shift;
	
	if($str =~ m/\w+="(.+?)"/){ return f2var($o,$1); }
	
	return '';
}

return 1;



