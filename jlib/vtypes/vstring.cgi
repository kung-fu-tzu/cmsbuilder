# Безразмерная строка ####################################################

$vtypes{'vstring'}{'table_cre'} = sub {
    
    my %elem = %{$_[0]};
    
    return ' TEXT ';
};

$vtypes{'vstring'}{'aview'} = sub {
    
    my $name = shift;
    my $val = shift;
    
    $val =~ s/\&/\&amp;/g;
    $val =~ s/\"/\&quot;/g;
    $val =~ s/\</\&lt;/g;
    $val =~ s/\>/\&gt;/g;
    
    my $ret = '<input class="winput" type=text name="'.$name.'" value="'.$val.'">';
    
    return $ret;
};

1;