# Текст #####################################################

$vtypes{'text'}{'table_cre'} = sub {
    
    my %elem = %{$_[0]};
    
    return ' TEXT ';
};

$vtypes{'text'}{'aview'} = sub {
    
    my $name = shift;
    my $val = shift;
    
    $val =~ s/\&/\&amp;/g;
    $val =~ s/\"/\&quot;/g;
    $val =~ s/\</\&lt;/g;
    $val =~ s/\>/\&gt;/g;
    
    my $ret = '<textarea class="winput" cols=42 rows=15 name="'.$name.'">'.$val.'</textarea>';
    
    return $ret;
};

1;