# (с) Леонов П.А., 2005

package CMSBuilder::EML;
use strict qw(subs vars);

use CMSBuilder;
use CMSBuilder::IO;
use CMSBuilder::IO::Session;
import CGI 'param';

###################################################################################################
# Базовые переменные интерфейса
###################################################################################################

our(@head,@pull,$dir,$path,%sess,$part_num);
our $daparser;

sub init
{
	@head = @pull = ();
	%sess = ();
	$part_num = $daparser = $dir = $path = undef;
}

sub doall
{
	my $cn = shift;
	my $eml = $cn->new();

	$eml->init_normal();
	
	$eml->parse();
	$eml->construct();
	$eml->execute();
	
	$daparser = $eml;
	
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

sub index
{
	my $obj = plgnSite->main();
	
	param('a');
	$obj->site_page({CGI->Vars(), 'eml' => CMSBuilder::EML->parser(), 'main_obj' => $obj});
}

sub parse
{
	my $o = shift;
	
	unless(-f $o->{'file'})
	{
		#print '<!-- ','DATA 'x1000,' -->';
		
		my $myurl = $o->{'uri'};
		$myurl =~ s#\.ehtml.*##g;
		$myurl = substr($myurl,1);
		$myurl =~ s#/#::#g;
		
		my $obj = cmsb_url($myurl);
		
		return err404('File not found: '.$o->{'file'}) unless $obj && $obj->{'ID'};
		
		param('a');
		$obj->site_page({CGI->Vars(), 'eml' => $o, 'main_obj' => $obj});
		
		return;
	}
	
	my $emlf;
	unless(open($emlf,'<',$o->{'file'})){ err500('Can`t open (<) file: '.$o->{'file'}); }
	$o->{'data'} = join('',<$emlf>);
	close($emlf);
	
	# Считываем и парсим конструкции <!--#include ... -->
	chdir($o->{'dir'});
	$o->{'data'} =~ s/<!--#include\s+(.+)\s*-->/SSI($o,$1);/gei;
	chdir($o->{'cgi_dir'});
	
	# Считываем и парсим конструкции <?eml *** ?>
	$o->{'parts'} = [ split(/<\?eml((?:.|\n)+?)\?>/,$o->{'data'}) ];
}

sub execute
{
	my $o = shift;
	
	push @pull, $o;
	eval($o->{'code'});
	pop @pull;
	
	if($@ && $@ !~ /^OK/)
	{
		my $etext = $@.'eval("'.$o->{'parts'}[$part_num].'") in '.$o->{'file'};
		print STDERR $etext;
		err500($etext);
	}
}

sub construct
{
	my $o = shift;
	my $i;
	$o->{'parts'}[$#{ $o->{'parts'} }+1] = '';
	for($i=0;$i<=$#{ $o->{'parts'} };$i+=2)
	{
		$o->{'code'} .= 'print parser()->{\'parts\'}['.$i.']; $CMSBuilder::EML::part_num = '.($i+1).'; '.$o->{'parts'}[$i+1].';';
	}
}

sub init_normal
{
	my $o = shift;
	
	unless($ENV{'REDIRECT_STATUS'}){ err500('REDIRECT_STATUS'); }
	
	$o->{'uri'} = $ENV{'REQUEST_URI'};
	
	$o->{'cgi_dir'} = $ENV{'SCRIPT_FILENAME'};
	$o->{'cgi_dir'} =~ s/\/[^\/]+$/\//;
	
	$o->{'file'} = $ENV{'PATH_TRANSLATED'};
	$o->{'file'} =~ s/\\/\//g;
	
	$o->{'file'} =~ s/\.ehtml(\/.*)//;
	$o->{'path'} = $1;
	if($o->{'path'}){ $o->{'file'} .= '.ehtml'; }
	
	$o->{'dir'} = $o->{'file'};
	$o->{'dir'} =~ s/\/[^\/]+$/\//;
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

1;