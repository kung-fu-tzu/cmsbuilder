# (�) ������ �.�., 2005

package CMSBuilder::DBI::vtypes::timestamp;
use strict qw(subs vars);
our @ISA = 'CMSBuilder::DBI::VType';
# ��������� ����� ####################################################

sub table_cre
{
	return ' TIMESTAMP(14) ';
}

1;