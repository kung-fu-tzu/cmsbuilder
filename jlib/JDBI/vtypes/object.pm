package JDBI::vtypes::object;
our @ISA = 'JDBI::VType';
# Объект ###################################################

our $integrated = 1;

sub table_cre
{
	return ' INT(11) ';
}

sub aview
{
	my $class = shift;
	my $name = shift;
	my $val = shift;
	my $obj = shift;
	
	if(!$obj->{$name}){ return 'Недоступен'; }
	
	return $obj->{$name}->admin_name();
}

sub aedit
{
	my $class = shift;
	my $name = shift;
	my $val = shift;
	my $obj = shift;
	
	return $obj->{$name};
}

sub del
{
	my $class = shift;
	my $name = shift;
	my $val = shift;
	my $obj = shift;
	
	$obj->{$name}->del();
}

1;