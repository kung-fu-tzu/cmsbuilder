
# Временная метка ####################################################

$vtypes{'timestamp'}{'table_cre'} = sub {
    
    return ' TIMESTAMP ';
};

$vtypes{'timestamp'}{'aview'} = sub {};

$vtypes{'timestamp'}{'aedit'} = sub {};

1;