# (�) ������ �.�., 2005

package JDBI::vtypes::timestamp;
our @ISA = 'JDBI::VType';
# ��������� ����� ####################################################

sub table_cre
{
	return ' TIMESTAMP ';
}

1;