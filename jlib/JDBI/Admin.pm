package JDBI::Admin;
use CGI ('param');
use JDBI;
use strict qw(subs vars);
our @ISA = 'JDBI::Base';


###################################################################################################
# Методы автоматизации администрирования
###################################################################################################

sub admin_left
{
    my $o = shift;
    
    print '<nobr><img align="absmiddle" src="img/nx.gif">',$o->admin_name(),'</nobr><br>',"\n";
}

sub admin_name
{
    my $o = shift;
    my $ret;
    
    $ret = $o->name();
    
    $ret =~ s/\<(?:.|\n)+?\>//g;
    if(length($ret) > $JConfig::admin_max_left_name_len){ $ret = substr($ret,0,$JConfig::admin_max_left_name_len-1).'...' }
    
    if(!$ret){ $ret = ${ref($o).'::name'}.' без имени' }
    
    if(!$o->access('r')){ return '<nobr style="CURSOR: default">'.($o->{'_is_shcut'}?'<img align="absmiddle" src="img/shcut.gif">':'').'<img objstr="',$o->myurl(),'" align="absmiddle" src="'.$o->admin_icon().'">&nbsp;<span style="CURSOR: default" class="ahref"> '.$ret.' </span></nobr>'; }
    
    return '<nobr style="CURSOR: default">'.($o->{'_is_shcut'}?'<img align="absmiddle" src="img/shcut.gif">':'').'<img objstr="',$o->myurl(),'" align="absmiddle" src="'.$o->admin_icon().'">&nbsp;<span style="CURSOR: default" objstr="',$o->myurl(),'" '.($o->{'_is_shcut'}?'':'id="id_'.$o->myurl().'"').'>&nbsp;<a objstr="',$o->myurl(),'" target="admin_right" href="'.$o->admin_href().'">'.$ret.'</a>&nbsp;</span></nobr>';
}

sub admin_icon
{
    my $o = shift;
    if( ${ref($o).'::icon'} ){ return 'icons/'.ref($o).'.gif'; }
    return 'icons/default.gif';
}

sub admin_href
{
    my $o = shift;
    return 'right.ehtml?url='.$o->myurl();
}

sub admin_cmenu
{
    my $o = shift;
    if(!$o->access('r')){ print 'menus["',$o->myurl(),'"] = [];'; return; }
    
    print 'menus["',$o->myurl(),'"] = [';
    print '["Открыть","',$o->admin_href(),'"]';
    #print '/*',$o->{'_is_property'},'*/';
    if($o->access('w')){
        
        print ',["---","hr:"]';
        
        if($o->papa() and !$o->{'_is_property'}){
            print ',["Удалить","right.ehtml?url=',$o->{'_ARRAY'},'&act=dele&enum=',$o->{'_ENUM'},'&page=0","doDel()"]';
            if(!$o->{'_is_shcut'}){ print ',["Переместить...","right.ehtml?act=move2&url='.$o->papa()->myurl().'&enum='.$o->{'_ENUM'}.'"]' }
        }
    }
    
    if($o->access('c')){
        print ',["---","hr:"],["Разрешения...","right.ehtml?act=chmod&url=',$o->myurl(),'"]';
    }
    
    print '];';
}



sub admin_tree
{
    my $o = shift;
    my $to;
    $to = $o;
    
    my @tree;
    my @names;
    my $count = 0;
    
    print '<script>',"\n";
    
    do{
        $count++;
        push(@tree, $to);
        
    }while( $to = $to->papa() and $count < 50 );
    
    
    for $to (reverse @tree){
        push(@names, $to->admin_name());
        print 'SelectLeft(parent.frames.admin_left.document.all["id_'.$to->myurl().'"]);',"\n";
        print 'ShowMe(parent.frames.admin_left.document.all["dbi_'.$to->myurl().'"],parent.frames.admin_left.document.all["dbdot_'.$to->myurl().'"]); ',"\n";
    }
    
    
    print '</script>';
    
    print join(' :: ',@names);
}

sub admin_edit
{
    my $o = shift;
    my ($key,$val,@keys,$vtype);
    my $p = \%{ ref($o).'::props' };
    
    if($o->{'ID'} < 1){ $o->err_add('Объект не существует.'); return; }
    
    if( $#{ ref($o).'::aview' } > -1 ){ @keys = @{ ref($o).'::aview' }; }else{ @keys = keys( %$p ); }
    
    for $key (@keys){
        
        $val = param($key);
        $vtype = 'JDBI::vtypes::'.$p->{$key}{'type'};
        
        if(!$JDBI::group->{'html'} and !${$vtype.'::dont_html_filter'}){ $val = JDBI::HTMLfilter($val); }
        
        $val = $vtype->aedit($key,$val,$o);
        
        $o->{$key} = $val;
    }
    
    if($o->err_is()){ $o->{'_print'} = "Изменения частично внесены.<br>\n"; }
    else{ $o->{'_print'} = "Изменения успешно внесены.<br>\n"; }
}

sub admin_cre
{
    my $o = shift;
    my $where = shift;
    
    $o->{'_print'} = 'Создание элемента...';
    $o->admin_err_print();
    
    print '<p class="hr">Данные элемента:</p>';
    print '<table width="100%" border=0><tr><td align=center>';
    print '<form action="?" method="POST" enctype="multipart/form-data">',"\n";
    print '<input type="hidden" name="act" value="cre">',"\n";
    print '<input type="hidden" name="cname" value="',ref($o),'">',"\n";
    
    print '<input type="hidden" name="url" value="',$where->myurl(),'">',"\n";
    
    print '<table width="100%">';
    $o->admin_props();
    print '<tr><td></td><td align=right></td></tr></table>';
    
    print '<br><input type="submit" value="Добавить">';
    print '</form></td></tr></table>';
}

sub admin_view
{
    my $o = shift;
    
    $o->admin_err_print();

    
    print '<p class="hr">Данные элемента:</p>';
    print '<table width="100%" border=0><tr><td align=center>';
    print '<form action="?" ',($o->access('w')?'':'disabled'),' method="POST" enctype="multipart/form-data">',"\n";
    print '<input type="hidden" name="act" value="edit">',"\n";
    
    print '<input type="hidden" name="url" value="',$o->myurl(),'">';
    
    print '<table width="100%">';
    
    $o->admin_props();
    
    print '<tr id="hide1"><td></td><td><a onclick="ShowDetails()" href="#">Дополнительно &gt;&gt;</a></td></tr>';
    print '<tr style="DISPLAY: none" id="show1"><td valign=top>Создан:</td><td>',JDBI::fromTIMESTAMP($o->{'CTS'}),'</td></tr>';
    print '<tr style="DISPLAY: none" id="show2"><td valign=top>Изменён:</td><td>',JDBI::fromTIMESTAMP($o->{'ATS'}),'</td></tr>';
    
    my $chown = ($JDBI::group->{'root'})?'<a href="?act=chown&url='.$o->myurl().'"><u>':'';
    my $tu = User->new();
    $tu->load($o->{'OID'});
    print '<tr style="DISPLAY: none" id="show3"><td valign=top>',$chown,'Владелец</u></a>:</td><td>',$tu->name(),'</td></tr>';
    $tu->clear();
    
    my $chmod = $o->access('c')?'<a href="?act=chmod&url='.$o->myurl().'"><u>':'';
    print '<tr style="DISPLAY: none" id="show4"><td valign=top>',$chmod,'Разрешения:</u></a></td><td>',$o->access_print(),'.</td></tr>';
    print '<tr style="DISPLAY: none" id="show5"><td valign=top>HTTP адрес:</td><td>',$o->des_href(),'</td></tr>';
    
    print '<tr><td></td><td align=right></td></tr></table>';
    
    if($o->access('w')){ print '<center><br><input type="submit" value="Сохранить"></center>'; }
    
    print '</form></td></tr></table>';
}

sub admin_props
{
    my $o = shift;
    my ($key,@keys,$vtype);
    
    my $p = \%{ ref($o).'::props' };
    
    if( $#{ ref($o).'::aview' } > -1 ){ @keys = @{ ref($o).'::aview' }; }else{ @keys = keys( %$p ); }
    for $key (@keys){
        $vtype = 'JDBI::vtypes::'.$p->{$key}{'type'};
        if(${ $vtype.'::admin_own_html' }){
            print $vtype->aview( $key, $o->{$key}, $o );
        }else{
            print '<tr><td valign=top width="20%" valign="center"><label for="',$key,'">',$p->{$key}{'name'},':</td><td width="80%" align="left" valign="middle">';
            print $vtype->aview( $key, $o->{$key}, $o );
            print '</td></tr>';
        }
    }
}

sub admin_err_print
{
    my $o = shift;
    
    if($o->err_is()){
        
        print '<table align="center"><tr><td class="mes_table"><font color="red">Возникла ошибка!</font><br><br>';
        $o->err_print();
        print '</td></tr></table><br>';
    }
    
    if($o->{'_print'}){
        
        print '<table align="center"><tr><td class="mes_table">',$o->{'_print'},'</td></tr></table><br>';
        $o->{'_print'} = '';
    }
}

return 1;