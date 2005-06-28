# (с) Леонов П.А., 2005

package JDBI::vtypes::object;
our @ISA = 'JDBI::VType';
# Объект ###################################################

our $filter = 1;

sub table_cre
{
	return ' INT(11) ';
}

sub filter_insert
{
	my $c = shift;
	my $name = shift;
	my $hc = shift;
	
	my $p = $hc->props();
	
	$to = $p->{$name}{'class'}->cre();
	
	return $to->{'ID'};
}

sub filter_load
{
	my $c = shift;
	my $name = shift;
	my $val = shift;
	my $obj = shift;
	
	my $to;
	my $p = $obj->props();
	
	$to = $p->{$name}{'class'}->new($val);
	$to->{'PAPA_ID'} = $obj->{'ID'};
	$to->{'PAPA_CLASS'} = ref($obj);
	
	$to->{'_is_property'} = 1;
	
	return $to;
}

sub filter_save
{
	my $c = shift;
	my $name = shift;
	my $val = shift;
	my $obj = shift;
	
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
	my $name = shift;
	my $val = shift;
	my $obj = shift;
	
	unless($obj->{$name}){ return 'Недоступен'; }
	
	return $obj->{$name}->admin_name();
}

sub aedit
{
	my $c = shift;
	my $name = shift;
	my $val = shift;
	my $obj = shift;
	
	return $obj->{$name};
}

sub del
{
	my $c = shift;
	my $name = shift;
	my $val = shift;
	my $obj = shift;
	
	$obj->{$name}->del();
}

1;