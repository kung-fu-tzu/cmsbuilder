package JDBI::vtypes::radio;
our @ISA = 'JDBI::VType';
# Переключатель #############################################

sub table_cre
{
    return ' INT(11) ';
}

1;