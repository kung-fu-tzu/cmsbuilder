# (с) Леонов П.А., 2005

package CMSBuilder::DBI::vtypes::object;
use strict qw(subs vars);
our @ISA = 'CMSBuilder::DBI::VType';
# Объект ###################################################

our $filter = 1;

sub table_cre
{
	return ' INT(11) ';
}

sub filter_insert
{
	my $c = shift;
	my ($name,$hc) = @_;
	
	my $p = $hc->props();
	
	my $to = $p->{$name}{'class'}->cre();
	
	return $to->{'ID'};
}

sub filter_load
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
	
	my $to;
	my $p = $obj->props();
	
	if($val)
	{
		$to = $p->{$name}{'class'}->new($val);
	}
	
	unless($to && $to->{'ID'})
	{
		$to = $p->{$name}{'class'}->cre();
		$to->papa_set($obj);
	}
	
	return $to;
}

sub filter_save
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
	
	if($val)
	{
		$val->save();
		return $val->{'ID'};
	}
	else
	{
		return 0;
	}
}

sub aview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	unless($obj->{$name}){ return 'Недоступен'; }
	
	return $obj->{$name}->admin_name();
}

sub aedit
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	return $obj->{$name};
}

sub del
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
	
	$obj->{$name}->del();
}

sub copy
{
	my $c = shift;
	my ($name,$val,$obj,$nobj) = @_;
	
	$val->copyto($nobj->{$name});
	
	return $nobj->{$name};
}

1;