# Строка ####################################################

$vtypes{'string'}{'table_cre'} = sub {
    
    my %elem = %{$_[0]};
    
    return ' VARCHAR( '.$elem{length}.' ) ';
};

$vtypes{'string'}{'aview'} = sub {
    
    my $name = shift;
    my $val = shift;
    
    $val =~ s/\"/\&quot;/g;
    $val =~ s/\</\&lt;/g;
    $val =~ s/\>/\&gt;/g;
    
    my $ret = '<input class="winput" type=text name="'.$name.'" value="'.$val.'">';
    
    return $ret;
};

$vtypes{'string'}{'aview'} = sub {
    
    my $name = shift;
    my $val = shift;
    
    $val =~ s/\"/\&quot;/g;
    $val =~ s/\</\&lt;/g;
    $val =~ s/\>/\&gt;/g;
    
    my $ret = '<input class="winput" type=text name="'.$name.'" value="'.$val.'">';
    
    return $ret;
};

1;