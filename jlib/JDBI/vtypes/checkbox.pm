package JDBI::vtypes::checkbox;
our @ISA = 'JDBI::VType';
# Галочка ###################################################

sub table_cre
{
    return ' INT(1) ';
}

sub aview
{
    my $class = shift;
    my $name = shift;
    my $val = shift;
    
    if($val){$val = 'checked'}
    
    my $ret = "<input type=checkbox name='$name' $val>";
    
    return $ret;
}

sub aedit
{
    my $class = shift;
    my $name = shift;
    my $val = shift;
    
    if($val){$val = 1}
    
    return $val;
}

1;