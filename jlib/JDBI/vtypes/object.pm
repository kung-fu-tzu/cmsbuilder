# (�) ������ �.�., 2005

package JDBI::vtypes::object;
our @ISA = 'JDBI::VType';
# ������ ###################################################

our $filter = 1;

sub table_cre
{
	return ' INT(11) ';
}

sub filter_load
{
	my $class = shift;
	my $name = shift;
	my $val = shift;
	my $obj = shift;
	
	my $to;
	my $p = $obj->props();
	
	unless($val)
	{
		$to = $p->{$name}{'class'}->cre();
		$to->{'PAPA_ID'} = $obj->{'ID'};
		$to->{'PAPA_CLASS'} = ref($obj);
		$to->save();
		
		$obj->{'_save_after_reload'} = 1;
	}
	else
	{
		$to = $p->{$name}{'class'}->new($val);
	}
	
	$to->{'_is_property'} = 1;
	
	return $to;
}

sub filter_save
{
	my $class = shift;
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
	
	unless($obj->{$name}){ return '����������'; }
	
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