package JDBI::Base;
use strict qw(subs vars);


###################################################################################################
# Методы выполняющие поиск объектов
###################################################################################################

sub sel_one
{
    my $class = shift;
    my $wh = shift;
    
    my $str = $JDBI::dbh->prepare('SELECT ID FROM `dbo_'.$class.'` WHERE '.$wh.' LIMIT 1');
    $str->execute(@_);
    
    my ($id) = $str->fetchrow_array();
    
    if(!$id){ return undef; }
    
    return $class->new($id);
}

sub sel_where
{
    my $class = shift;
    my $wh = shift;
    
    my $id;
    my @oar;
    
    my $str = $JDBI::dbh->prepare('SELECT ID FROM `dbo_'.$class.'` WHERE '.$wh);
    $str->execute(@_);
    
    while( ($id) = $str->fetchrow_array() ){ push(@oar,$class->new($id)) }
    
    return @oar;
}

sub sel_sql
{
    my $class = shift;
    my $wh = shift;
    
    my $res;
    my @oar;
    
    my $str = $JDBI::dbh->prepare($wh);
    $str->execute(@_);
    
    while( $res = $str->fetchrow_hashref('NAME_lc') ){ push(@oar,$class->new($res->{'id'})) }
    
    return @oar;
}


###################################################################################################
# Методы для непосредственной работы с Базой Данных
###################################################################################################

sub IDs
{
    my $o = shift;
    my $col = shift;
    my $lim = shift;
    my $id = 0;
    my @ar;
    
    if(!$col){ $col = 'ID' }
    if($lim){ $lim = ' LIMIT '.$lim }
    
    my $str = $JDBI::dbh->prepare('SELECT ID FROM `dbo_'.ref($o).'` ORDER BY '.$col.$lim);
    $str->execute();
    
    while( ($id) = $str->fetchrow_array() ){
        push @ar, $id;
    }
    
    return @ar;
}

sub count
{
    my $o = shift;
    
    my $str = $JDBI::dbh->prepare('SELECT COUNT(ID) FROM `dbo_'.ref($o).'`');
    $str->execute();
    
    my ($res) = $str->fetchrow_array();
    
    return $res;
}

sub del
{
    my $o = shift;
    my $key;
    my $p = \%{ ref($o).'::props' };
    
    if($o->{'_temp_object'}){ $o->clear(); return; }
    if($o->{'ID'} < 1){ $o->clear(); return; }
    if($o->{'ID'} =~ m/\D/){ JIO::err505('DBO: Non-digital ID passed to del(), '.ref($o).', '.$o->{'ID'}); }
    
    my $papa = $o->papa();
    if(!$papa){
        if(!$o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
    }else{
        if(!$papa->access('x')){ $o->err_add('У Вас нет разрешения изменять родителя этого элемента.'); return; }
    }
    
    for $key (keys( %$p )){
        
        my $vtype = 'JDBI::vtypes::'.$p->{$key}{'type'};
        $vtype->del( $key, $o->{$key}, $o );
    }
    
    my $str = $JDBI::dbh->prepare('DELETE FROM `dbo_'.ref($o).'` WHERE ID = ? LIMIT 1');
    $str->execute($o->{'ID'});
    
    $o->clear();
}

sub reload
{
    my $o = shift;
    my $key;
    my $p = \%{ ref($o).'::props' };
    
    if($o->{'ID'} < 1){ return; }
    if($o->{'ID'} =~ m/\D/){ JIO::err505('DBO: Non-digital ID passed to reload(), '.ref($o).", $o->{'ID'}"); }
    
    my $str = $JDBI::dbh->prepare('SELECT * FROM `dbo_'.ref($o).'` WHERE ID = ? LIMIT 1');
    $str->execute($o->{'ID'});
    
    my $res = $str->fetchrow_hashref('NAME_lc');
    
    if($res->{'id'} != $o->{'ID'}){ print STDERR 'DBO: Loading from not existed row, class = "'.ref($o).'",ID = '.$o->{'ID'}."\n"; $o->clear(); return; }
    
    my $id = 0;
    my $have_o = 0;
    
    for $key (keys( %$p )){
        $o->{$key} = $res->{$key};
        
        if( $p->{$key}{'type'} eq 'object' ){
            
            $id = $o->{$key};
            if($id < 1){ $o->{$key} = $p->{$key}{'class'}->cre(); $have_o = 1; }
            else{ $o->{$key} = $p->{$key}{'class'}->new($id); }
            $o->{$key}->{'PAPA_ID'} = $o->{'ID'};
            $o->{$key}->{'PAPA_CLASS'} = ref($o);
            $o->{$key}->{'PAPA_CLASS'} = ref($o);
            $o->{$key}->{'_is_property'} = 1;
        }
    }
    
    $o->{'PAPA_ID'} = $res->{'papa_id'};
    $o->{'PAPA_CLASS'} = $res->{'papa_class'};
    $o->{'OID'} = $res->{'oid'};
    $o->{'CTS'} = $res->{'cts'};
    $o->{'ATS'} = $res->{'ats'};
    
    
    if(!$o->access('r')){
        
        my $t_name = $o->name();
        $o->clear_data();
        $o->{'name'} = $t_name; #'Чтение не разрешено';
    }
    
    if($have_o == 1){ $o->save() }
}

sub save
{
    my $o = shift;
    my $key;
    my $p = \%{ ref($o).'::props' };
    my @vals = ();
    my $val;
    
    if($o->{'_temp_object'}){ return; }
    if($o->{'ID'} < 1){ return; }
    if(!$o->access('w')){ return; }
    if($o->{'ID'} =~ m/\D/){ JIO::err505('DBO: Non-digital ID passed to save(), '.ref($o).', '.$o->{'ID'}); }
    
    #print 'Saving: ',$o->myurl(),'<br>';
    $o->{'_modifide'} = 0;
    
    my $sql = 'UPDATE `dbo_'.ref($o).'` SET ';
    $sql .= ' OID = ?, PAPA_ID = ?, PAPA_CLASS = ?, ';
    
    for $key (keys( %$p )){
        $sql .= "\n $key = ?,";
        
        if( $p->{$key}{'type'} eq 'object' ){
            
            if($o->{$key}){
                $o->{$key}->save();
                $val = $o->{$key}->{'ID'};
            }else{
                $val = -1;
            }
        }
        else{ $val = $o->{$key}; }
        
        push @vals, $val;
        
    }
    
    chop($sql);
    
    $sql .=  "\n".' WHERE ID = ? LIMIT 1';
    
    my $str;
    $str = $JDBI::dbh->prepare($sql);
    #print $str;
    #print 'url = [',$o->myurl(),']';
    $str->execute($o->{'OID'},$o->{'PAPA_ID'},$o->{'PAPA_CLASS'},@vals,$o->{'ID'});
}

sub insert
{
    my $o = shift;
    my $str;
    
    $str = $JDBI::dbh->prepare('INSERT INTO `dbo_'.ref($o).'` (OID,CTS) VALUES (?,NOW())');
    $str->execute(JDBI::user()->{'ID'});
    
    $str = $JDBI::dbh->prepare('SELECT LAST_INSERT_ID() FROM `dbo_'.ref($o).'` LIMIT 1');
    $str->execute();
    my $id;
    
    ($id) = $str->fetchrow_array();
    
    return $id;
}


###################################################################################################
# Вспомогательные методы работы с Базой Данных
###################################################################################################

sub save_as
{
    my $o = shift;
    my $n = shift;
    
    $o->{'ID'} = $n;
    $o->save();
    
    return $n;
}

sub save_to
{
    my $o = shift;
    my $n = shift;
    my $t = 0;
    
    $t = $o->{'ID'};
    $o->{'ID'} = $n;
    $o->save();
    $o->{'ID'} = $t;
    
    return $n;
}

sub loadr
{
    my $o = shift;
    my $n = shift;
    
    $o->clear();
    
    $o->{'ID'} = $n;
    $o->reload();
}

sub load
{
    my $o = shift;
    my $n = shift;
    
    $o->save();
    $o->clear();
    
    $o->{'ID'} = $n;
    $o->reload();
}

sub clear
{
    my $o = shift;
    my $key;
    
    for $key (keys( %$o )){ $o->{$key} = ''; }
    
    $o->{'ID'} = 0;
}

sub clear_data
{
    my $o = shift;
    my $key;
    my $p = \%{ ref($o).'::props' };
    
    for $key (keys( %$p )){ $o->{$key} = ''; }
}

sub creTABLE
{
    my $o = shift;
    
    if(ref($o)){
        return JDBI::creTABLE(ref($o),@_);
    }else{
        return JDBI::creTABLE($o,@_);
    }
}

return 1;