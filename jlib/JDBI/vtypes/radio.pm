# (�) ������ �.�., 2005

package JDBI::vtypes::radio;
our @ISA = 'JDBI::VType';
# ������������� #############################################

sub table_cre
{
	return ' INT(11) ';
}

1;