package JDBI::VType;

our $filter;	# При загрузке этого виртуального типа, полю будет присвоено
				# автоматическое значение ( ф-ции filter_in() и filter_out() )

our $virtual;	# Не имеет столбца в таблице

sub table_cre
{
	return ' VARCHAR(100) ';
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
	
	return '<input class="winput" type="text" name="'.$name.'" value="'.$val.'">';
}

sub aedit
{
	my $class = shift;
	my $name = shift;
	my $val = shift;
	
	return $val;
}

sub del
{
	my $class = shift;
	my $name = shift;
	my $val = shift;
	my $obj = shift;
}

1;