# (с) Леонов П. А., 2005

package fltGZIP;
our @ISA = 'CMSBuilder::IO::Filter';

use Compress::Zlib;

sub filt
{
	my $c = shift;
	my $str = shift;
	my $hdrs = shift;
	
	unless(send_gzipped()){ return; }
	
	$$str = Compress::Zlib::memGzip($$str);
	$hdrs->{'Content-Length'} = length($$str);
}

sub send_gzipped { return ($CMSBuilder::Config::buff_gzip && $ENV{'HTTP_ACCEPT_ENCODING'} =~ /gzip/); }

1;