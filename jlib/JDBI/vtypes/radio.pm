package JDBI::vtypes::radio;
our @ISA = 'JDBI::VType';
# ������������� #############################################

sub table_cre
{
    return ' INT ';
}

1;