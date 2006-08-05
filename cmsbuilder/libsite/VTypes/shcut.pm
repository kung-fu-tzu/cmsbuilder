# (с) Леонов П.А., 2005

package CMSBuilder::DBI::vtypes::shcut;
use strict qw(subs vars);
use utf8;

our @ISA = 'CMSBuilder::DBI::VType';
# Объект ###################################################

our $filter = 1;

use CMSBuilder;

sub table_cre {'VARCHAR(50)'}

sub filter_insert { return ''; }

sub filter_load
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
	
	return $val?cmsb_url($val):undef;
}

sub filter_save
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
	
	if($val && ref $val)
	{
		return $val->myurl();
	}
	else
	{
		return '';
	}
}

sub aview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	return ref $obj->{$name}?$obj->{$name}->admin_name():'пусто';
}

sub aedit
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	return $obj->{$name};
}

1;