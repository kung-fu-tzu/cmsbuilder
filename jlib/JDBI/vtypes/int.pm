package JDBI::vtypes::int;
our @ISA = 'JDBI::VType';
# Число ####################################################

sub table_cre
{
    return ' INT ';
}

sub aview
{
    my $class = shift;
    my $name = shift;
    my $val = shift;
    
    my $ret = "<input width=50 type=text name='$name' value=\"$val\">";
    
    return $ret;
}

sub aedit
{
    my $class = shift;
    my $name = shift;
    my $val = shift;
    
    $val =~ s/\D//g;
    if($val eq ''){ $val = 0; }
    
    return $val;
}

1;