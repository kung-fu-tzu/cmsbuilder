# Число ####################################################

$vtypes{'int'}{'table_cre'} = sub {
    
    return ' INT ';
};

$vtypes{'int'}{'aview'} = sub {
    
    my $name = shift;
    my $val = shift;
    
    my $ret = "<input width=50 type=text name='$name' value=\"$val\">";
    
    return $ret;
};

$vtypes{'int'}{'aedit'} = sub {
    
    my $name = shift;
    my $val = shift;
    
    $val =~ s/\D//g;
    if($val eq ''){ $val = 0; }
    
    return $val;
};

1;