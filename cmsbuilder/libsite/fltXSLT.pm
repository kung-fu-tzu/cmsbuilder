# (�) ������ �. �., 2005

package fltXSLT;
use strict qw(subs vars);
our @ISA = ('CMSBuilder::IO::Filter');

use XML::XSLT;
use CMSBuilder::Utils;

#-------------------------------------------------------------------------------

push @XML::Parser::Expat::Encoding_Path, $CMSBuilder::Config::path_etc.'/xmlenc';

our $doparse = 0;

sub doparse { $doparse = $_[1] }

sub filt
{
	my $c = shift;
	my $str = shift;
	my $hdrs = shift;
	
	unless($doparse){ return; }
	$doparse = 0;
	
	unless($$str =~ m#<\?xml-stylesheet.+?href="(.+?)"\?>#)
	{
		print STDERR "$c: stylesheet is not defined in ".$CMSBuilder::EML::daparser->{'file'};
		return;
	}
	
	my $file = $1;
	if($file =~ m#^/.+#){ $file = $CMSBuilder::Config::path_htdocs.$file; }
	chdir($CMSBuilder::EML::daparser->{'dir'});
	unless(-f $file){ print STDERR "$c: no surch file '$file'"; return; }
	my $xsl = f2var($file);
	
	my $xslt = XML::XSLT->new($xsl, 'warnings' => 1);
	$xslt->transform($$str);
	
	
	$$str = $xslt->toString;
	$hdrs->{'Content-Type'} = 'text/html; charset=utf-8';
}

1;