# Пароль ####################################################

$vtypes{'password'}{'table_cre'} = sub {
    
    my %elem = %{$_[0]};
    
    return ' VARCHAR( '.$elem{length}.' ) ';
};

$vtypes{'password'}{'aview'} = sub {
    
    my $name = shift;
    my $val = shift;
    
    $val =~ s/./*/g;
    
    my $ret = '<input class="winput" type=password name="'.$name.'" value="'.$val.'">';
    
    return $ret;
};

$vtypes{'password'}{'aedit'} = sub {
    
    my $name = shift;
    my $val = shift;
    my $obj = shift;
    
    $old = $obj->{$name};
    $old =~ s/./*/g;
    
    if($val eq $old){ return $obj->{$name}; }
    if($val eq ''){ return $obj->{$name}; }
    
    return $val;
};

1;