# CMSBuilder © Леонов П. А., 2005-2006

package CMSBuilder::SysUtils;
use strict;
use warnings;
use utf8;

use warnings::register;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw();
our @EXPORT_OK = qw(carp croak VIRTUAL);


our $virtual_warn_sub = \&carp;


sub carp($)
{
	require Carp unless *Carp::carp;
	
	goto &Carp::carp;
}

sub croak($)
{
	require Carp unless *Carp::croak;
	
	goto &Carp::croak;
}

sub VIRTUAL()
{
	my ($package, , , $subroutine) = caller;
	
	my $mess = 'Tried to call virtual method "' . $subroutine . '" of "' . $package . '"';
	
	local $Carp::CarpLevel = 1;
	$virtual_warn_sub->($mess) if warnings::enabled;
	
	return;
}

# warnings::warnif $package, 'Try call of virtual method "' . $subroutine . '"';

#my ($package, $filename, $line, $subroutine, $hasargs,
#    $wantarray, $evaltext, $is_require, $hints, $bitmask) = caller($i);

1;