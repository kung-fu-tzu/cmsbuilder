# Объект ###################################################

$vtypes{'object'}{table_cre} = sub {
    
    return ' INT ';
};

$vtypes{'object'}{'aview'} = sub {
    
    my $name = shift;
    my $val = shift;
    my $obj = shift;
    
    if(!$obj->{$name}){ return 'Недоступен'; }
    
    my %props = $obj->props();
    
    my $ret = "<a href=?url=".$obj->{$name}->myurl().">".$obj->{$name}->name()."</a>";
    
    return $ret;
};

$vtypes{'object'}{'aedit'} = sub {
    
    my $name = shift;
    my $val = shift;
    my $obj = shift;
    
    return $obj->{$name};
};

$vtypes{'object'}{'del'} = sub {
    
    my $name = shift;
    my $val = shift;
    my $obj = shift;
    
    $obj->{$name}->del();
};

1;