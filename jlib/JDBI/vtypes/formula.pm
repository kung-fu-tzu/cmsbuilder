package JDBI::vtypes::formula;
our @ISA = 'JDBI::VType';
# Формула ####################################################

our $virtual = 1;

sub aview
{
	my $class = shift;
	my $name = shift;
	my $val = shift;
	my $obj = shift;
	my $ret;
	
	$ret = join(',',keys(%$obj));
	
	return $ret;
}

sub aedit
{
	my $class = shift;
	my $name = shift;
	my $val;
	
	return $val;
}

1;