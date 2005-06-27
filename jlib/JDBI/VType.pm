# (с) Леонов П.А., 2005

# Базовый класс для вируальных типов.
package JDBI::VType;

our $filter;	# При загрузке этого виртуального типа, полю будет присвоено
				# автоматическое значение ( ф-ции filter_in() и filter_out() )

our $virtual;	# Не имеет столбца в таблице

our $admin_own_html;	# aview() возвращает не значение, а весь HTML код.
						# Пример: JDBI::vtypes::miniword

#-------------------------------------------------------------------------------


sub table_cre
{
	return ' CHAR(100) ';
}

sub aview
{
	my $class = shift;
	my $name = shift;
	my $val = shift;
	my $obj = shift;
	
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

sub filter_load
{
	my $class = shift;
	my $name = shift;
	my $val = shift;
	my $obj = shift;
}

sub filter_save
{
	my $class = shift;
	my $name = shift;
	my $val = shift;
	my $obj = shift;
}

sub del
{
	my $class = shift;
	my $name = shift;
	my $val = shift;
	my $obj = shift;
}

1;