# Галочка ###################################################

$vtypes{'checkbox'}{'table_cre'} = sub {
    
    my %elem = %{$_[0]};
    
    return ' INT ';
};

$vtypes{'checkbox'}{'aview'} = sub {
    
    my $name = shift;
    my $val = shift;
    
    if($val){$val = 'checked'}
    
    my $ret = "<input type=checkbox name='$name' $val>";
    
    return $ret;
};

$vtypes{'checkbox'}{'aedit'} = sub {
    
    my $name = shift;
    my $val = shift;
    
    if($val){$val = 1}
    
    return $val;
};

1;