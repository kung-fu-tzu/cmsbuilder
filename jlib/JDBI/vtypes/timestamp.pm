# (с) Леонов П.А., 2005

package JDBI::vtypes::timestamp;
our @ISA = 'JDBI::VType';
# Временная метка ####################################################

sub table_cre
{
	return ' TIMESTAMP ';
}

1;