package JDBI::vtypes::vstring;
our @ISA = 'JDBI::VType';
# Безразмерная строка ####################################################

sub table_cre
{
	return ' TEXT ';
}

sub aview
{
	my $class = shift;
	my $name = shift;
	my $val = shift;
	
	$val =~ s/\&/\&amp;/g;
	$val =~ s/\"/\&quot;/g;
	$val =~ s/\</\&lt;/g;
	$val =~ s/\>/\&gt;/g;
	
	my $ret = '<input class="winput" type=text name="'.$name.'" value="'.$val.'">';
	
	return $ret;
}

1;