# CMSBuilder © Леонов П. А., 2006

package CMSBuilder::DBI::vtypes::moveToBasket;
use strict qw(subs vars);
use utf8;

our @ISA = 'CMSBuilder::DBI::VType';
# Список ####################################################

our $virtual = 1;
our $property = 1;

sub prop_read
{
	my $c = shift;
	my ($name,$obj) = @_;
	
	return $obj->{$name}.$obj;
}

sub prop_write
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
	
	return $obj->{$name} = $val;
}

1;