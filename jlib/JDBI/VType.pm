# (�) ������ �.�., 2005

# ������� ����� ��� ���������� �����.
package JDBI::VType;

our $filter;	# ��� �������� ����� ������������ ����, ���� ����� ���������
				# �������������� �������� ( �-��� filter_in() � filter_out() )

our $virtual;	# �� ����� ������� � �������

our $admin_own_html;	# aview() ���������� �� ��������, � ���� HTML ���.
						# ������: JDBI::vtypes::miniword

#-------------------------------------------------------------------------------


sub table_cre
{
	return ' CHAR(100) ';
}

sub aview
{
	my $c = shift;
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
	my $c = shift;
	my $name = shift;
	my $val = shift;
	
	return $val;
}

sub filter_insert
{
	my $c = shift;
	my $name = shift;
}

sub filter_load
{
	my $c = shift;
	my $name = shift;
	my $val = shift;
	my $obj = shift;
}

sub filter_save
{
	my $c = shift;
	my $name = shift;
	my $val = shift;
	my $obj = shift;
}

sub del
{
	my $c = shift;
	my $name = shift;
	my $val = shift;
	my $obj = shift;
}

1;