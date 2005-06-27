# (с) Леонов П.А., 2005

package JDBI::vtypes::string;
our @ISA = 'JDBI::VType';
# Строка ####################################################

sub table_cre
{
	my $class = shift;
	my %elem = %{$_[0]};
	
	return ' CHAR( '.$elem{length}.' ) ';
}

sub aview
{
	my $class = shift;
	my $name = shift;
	my $val = shift;
	
	$val =~ s/\"/\&quot;/g;
	$val =~ s/\</\&lt;/g;
	$val =~ s/\>/\&gt;/g;
	
	my $ret = '<input class="winput" type=text name="'.$name.'" value="'.$val.'">';
	
	return $ret;
}

1;