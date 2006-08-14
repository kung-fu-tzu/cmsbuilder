# CMSBuilder © Леонов П. А., 2005-2006

package fltGZIP;
use strict qw(vars subs);
use utf8;

our @ISA = 'CMSBuilder::IO::Filter';

use Compress::Zlib;

sub filt
{
	my $c = shift;
	my $str = shift;
	my $hdrs = shift;
	
	unless($ENV{'HTTP_ACCEPT_ENCODING'} =~ /gzip/){ return; }
	
	$$str = Compress::Zlib::memGzip($$str);
	$hdrs->{'Content-Length'} = length($$str);
}

1;