package JDBI::Array;
use strict qw(subs vars);
our @ISA = 'JDBI::Object';
use JIO;


###################################################################################################
# Следующие методы находятся в разработке
###################################################################################################



###################################################################################################
# Методы автоматизации администрирования
###################################################################################################

sub admin_left
{
    my $o = shift;
    
    if( ${ref($o).'::dont_list_me'} ){ return $o->SUPER::admin_left(@_); }
    if( $o->{'_is_shcut'} ){ return $o->SUPER::admin_left(@_); }
    
    my %node = $JDBI::cgi->cookie( 'dbi_'.$o->myurl() );
    my $disp = $node{'s'} ? 'block' : 'none';
    my $pic  = $node{'s'} ? 'minus' : 'plus';
    
    print '<nobr><img align="absmiddle" id="dbdot_'.$o->myurl().'" src="img/'.$pic.'.gif" onclick="ShowHide(dbi_'.$o->myurl().',dbdot_'.$o->myurl().')">',$o->admin_name(),'</nobr><br>',"\n";
    
    print '<div id="dbi_'.$o->myurl().'" class="left_dir" style="DISPLAY: '.$disp.';">',"\n";
    
    my $to;
    for $to ($o->get_all($JConfig::admin_max_left)){ $to->admin_left() }
    
    if($o->len() > $JConfig::admin_max_left){ print '<nobr><font color="#ff7300" size=1>Элементов слишком много...</font></nobr><br>',"\n"; }
    print '</div>',"\n";
}

sub admin_cre
{
    my $o = shift;
    return $o->SUPER::admin_cre(@_);
}

sub admin_view
{
    my $o = shift;
    my $page = shift;
    my $e;
    my $i = 0;
    my($up,$down);
    
    $o->SUPER::admin_view();
    
    if(!$o->access('r')){ return; }
    
    print '<p class="hr">Список вложенных элементов:</p>';
    
    my $len = $o->len();
    if(!$page){ $page = 0; }
    
    for $e ($o->get_page($page)){
	
	if($o->access('w')){
	    
	    $up =   ($e->{'_ENUM'} != 1)?'<a href="?act=eup&url='.$o->myurl().'&enum='.$e->{'_ENUM'}.'&page='.$page.'"><img border=0 align="absmiddle" alt="Переместить выше" src="img/up.gif"></a>':'<img align="absmiddle" src="img/nx.gif">';
	    $down = ($e->{'_ENUM'} != $len)?'<a href="?act=edown&url='.$o->myurl().'&enum='.$e->{'_ENUM'}.'&page='.$page.'"><img border=0 align="absmiddle" alt="Переместить ниже" src="img/down.gif"></a>':'<img align="absmiddle" src="img/nx.gif">';
	    
	    if(${ref($o).'::pages_direction'}){ print $up,$down; }else{ print $down,$up; }
	    
	}else{
	    print '<img align="absmiddle" src="img/nx.gif"><img align="absmiddle" src="img/nx.gif">';
	}
	
	print '<img align="absmiddle" src="img/nx.gif">';
	print $e->admin_name(),'<br>';
	$i++;
    }
    
    if(!$i){ print '<center>Нет элементов.</center>'; }
    
    if($o->pages() > 1){
	
	print '<br><br><center>';	
	print '<table class="pages_table" cellspacing="0" cellpadding="0"><tr>';
	
	my $p;
	for($p=0;$p<$o->pages();$p++){
	    
	    if($p == $page){ print '<td width=20 align=center height=20 bgcolor="#ff7300"><b>'.($p+1).'</b></td>'; }
	    else{ print '<td width=20 align=center height=20><a href="?url='.$o->myurl().'&page='.$p.'">'.($p+1).'</a><td>' }
	}
	
	print '</tr></table>';
	print '</center>';
    }
    
    my $c;
    
    if($o->access('a')){
	
	print '<form id="add_form" action="?">';
	print '<input type="hidden" name="act" value="adde">',"\n";
	print '<input type="hidden" name="url" value="',$o->myurl(),'">',"\n";
	
	print '<label id="add_label" for="add_cname">Добавить: </label><select id="add_cname" name="cname" onchange="add_form.submit()"><OPTION selected></OPTION>';
	for $c (@JDBI::classes){
	    
	    if( index( ${ref($o).'::add'}, ' '.$c.' ') < 0 and ${ref($o).'::add'} ne '*' ){ next; }
	    print "<option value='$c'>${$c.'::name'}</option>";
	}
	print '</select></form>';
    }
    
    print '<br><br>';
}


###################################################################################################
# Методы для работы со страницами
###################################################################################################

sub pages
{
    my $o = shift;
    
    my $len = $o->len();
    
    if(!$o->{'onpage'}){ $o->{'onpage'} = 20; }
    
    $len /= $o->{'onpage'};
    
    if($len != int($len)){ $len = int($len); $len++; }
    
    return $len;
}

sub get_page
{
    my $o = shift;
    my $page = shift;
    my @ret;
    #if(!$o->)
    
    if( ${ref($o).'::pages_direction'} )
	{ @ret = $o->get_page_inc($page) }
    else{ @ret = $o->get_page_dec($page) }
    
    return @ret;
}

sub get_all_class
{
    my $o = shift;
    my @classes = @_;
    my @ret;
    
    if( ${ref($o).'::pages_direction'} )
	{ @ret = $o->get_all_class_inc(@classes) }
    else{ @ret = $o->get_all_class_dec(@classes) }
    
    return @ret;
}

sub get_all_class_inc
{
    my $o = shift;
    my @classes = @_;
    
    my $to;
    my @ret;
    my $i = 1;
    
    
    while($to = $o->elem($i)){
	
	push @ret, $to;
	$i++;
    }
    
    return @ret;
}

sub get_all_class_dec
{
    my $o = shift;
    my @classes = @_;
    
    my $to;
    my @ret;
    my $i = $o->len();
    
    
    while($to = $o->elem($i)){
	
	push @ret, $to;
	$i--;
    }
    
    return @ret;
}

sub get_all
{
    my $o = shift;
    my $mlen = shift;
    my @ret;
    
    my $len = $o->len();
    if($mlen < 1){$mlen = $len}
    if($len > $mlen){ $len = $mlen; }
    
    if( ${ref($o).'::pages_direction'} )
	{ @ret = $o->get_all_inc($len) }
    else{ @ret = $o->get_all_dec($len) }
    
    return @ret;
}

sub get_all_inc
{
    my $o = shift;
    my $len = shift;
    
    my $to;
    my @ret;
    my $i = 1;
    my $count = 0;
    
    while($to = $o->elem($i) and $count <= $len){
	
	push @ret, $to;
	$i++;
	$count++;
    }
    
    return @ret;
}

sub get_all_dec
{
    my $o = shift;
    my $len = shift;
    
    my $to;
    my @ret;
    my $i = $o->len();
    my $count = 0;
    
    while($to = $o->elem($i) and $count <= $len){
	
	push @ret, $to;
	$i--;
	$count++;
    }
    
    return @ret;
}

sub get_page_dec
{
    my $o = shift;
    my $page = shift;
    $page =~ s/\D//g;
    
    if($page >= $o->pages()){ $page = $o->pages() - 1; }
    if(!$page){ $page = 0; }
    
    if(!$o->{'onpage'}){ $o->{'onpage'} = 20; }
    
    my $i = $o->{'onpage'} * $page;
    my $len = 0;
    my $to;
    my @ret;
    
    $i = $o->len() - $i;
    
    while($to = $o->elem($i) and $len < $o->{'onpage'}){
	
	push @ret, $to;
	
	$len++;
	$i--;
    }
    
    return @ret;
}

sub get_page_inc
{
    my $o = shift;
    my $page = shift;
    $page =~ s/\D//g;
    
    if($page >= $o->pages()){ $page = $o->pages() - 1; }
    if(!$page){ $page = 0; }
    
    if(!$o->{'onpage'}){ $o->{'onpage'} = 20; }
    
    my $i = $o->{'onpage'} * $page + 1;
    my $len = 0;
    my $to;
    my @ret;
    
    while($to = $o->elem($i) and $len < $o->{'onpage'}){
	
	push @ret, $to;
	
	$len++;
	$i++;
    }
    
    return @ret;
}


###################################################################################################
# Методы для работы с элементами
###################################################################################################

sub elem_del
{
    my $o = shift;
    my $eid = shift;
    if(!$o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
    my $obj = $o->elem($eid);
    if(!$obj){ $o->err_add($eid.$o->myurl()); return; }
    if(!$obj->access('w')){ $o->err_add('У Вас нет разрешения изменять удаляемый элемент.'); return; }
    
    $obj = $o->elem_cut($eid);
    $obj->del();
    
    $obj = '';
}

sub elem_moveup
{
    my $o = shift;
    my $num = shift;
    if(!$o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
    
    $o->elem_moveto($num,$num-2);
}

sub elem_movedown
{
    my $o = shift;
    my $num = shift;
    if(!$o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
    
    $o->elem_moveto($num,$num+1);
}

sub elem_paste
{
    my $o = shift;
    my $po = shift;
    if(!$o->access('a')){ $o->err_add('У Вас нет разрешения добавлять в этот элемент.'); return; }
    if(!$po->access('w')){ $o->err_add('У Вас нет разрешения изменять вставляемый элемент.'); return; }
    
    if($o->{'ID'} < 1){ return; }
    
    $o->elem_paste_ref($po);
    
    $po->{'PAPA_ID'} = $o->{'ID'};
    $po->{'PAPA_CLASS'} = ref($o);
    
    $po->save();
}

sub elem_paste_shcut
{
    my $o = shift;
    my $po = shift;
    if(!$o->access('a')){ $o->err_add('У Вас нет разрешения добавлять в этот элемент.'); return; }
    
    if($o->{'ID'} < 1){ return; }
    
    $o->elem_paste_ref($po,1);
}


###################################################################################################
# Методы для непосредственной работы с массивом
###################################################################################################

sub elem_paste_ref
{
    my $o = shift;
    my $po = shift;
    my $shcut = shift;
    if(!$o->access('a')){ $o->err_add('У Вас нет разрешения добавлять в этот элемент.'); return; }
    
    if($o->{'ID'} < 1){ return; }
    if($po->{'ID'} < 1){ return; }
    if(!$o->is_array_table()){ $o->create_array_table();  }
    
    if( !$o->elem_can_paste($po) ){ JIO::err505('Trying to add element with classname "'.ref($po).'", to array "'.ref($o).'"'); }
    
    my $str = $JDBI::dbh->prepare('INSERT INTO `arr_'.$o->myurl().'` (ID,CLASS,SHCUT) VALUES (?,?,?)');
    $str->execute($po->{'ID'},ref($po),$shcut?1:0);
    
    $o->sortT();
}

sub elem_can_paste
{
    my $o = shift;
    my $po = shift;
    if(!$o->access('a')){ return 0; }
    
    if( ${ref($o).'::add'} eq '*' ){ return 1 }
    if( index( ${ref($o).'::add'}, ' '.ref($po).' ') < 0 ){ return 0 }
    return 1;
}

sub elem
{
    my $o = shift;
    my $eid = shift;
    
    if(!$o->access('x')){ $o->err_add('У Вас нет разрешения просматривать этот элемент.'); return undef; }
    
    if($o->{'ID'} < 1){ return undef; }
    if(!$o->is_array_table()){ return undef; }
    
    my $str = $JDBI::dbh->prepare('SELECT * FROM `arr_'.$o->myurl().'` WHERE num = ? LIMIT 1');
    $str->execute($eid);
    
    my $res = $str->fetchrow_hashref('NAME_uc');
    
    if(!$res->{'CLASS'}){ return undef }
    
    my $to = $res->{'CLASS'}->new($res->{'ID'});
    $to->{'_ENUM'} = $eid;
    $to->{'_ARRAY'} = $o->myurl();
    
    if($res->{'SHCUT'}){ $to->{'_is_shcut'} = 1; }
    
    if(!$to->{'ID'}){
	
	#print '[',$eid,'-',$o->myurl(),']';
	$str = $JDBI::dbh->prepare('DELETE FROM `arr_'.$o->myurl().'` WHERE num = ? LIMIT 1');
	$str->execute($eid);
	sess()->{'admin_refresh_left'} = 1;
    }
    
    
    return $to;
}

sub elem_cut
{
    my $o = shift;
    my $eid = shift;
    if(!$o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
    
    if($o->{'ID'} < 1){ return; }
    
    my $to = $o->elem($eid);
    if(!$to){ return undef; }
    
    if(!$to->access('w')){ $o->err_add('У Вас нет разрешения изменять вырезаемый элемент.'); return; }
    
    if(!$to->{'_is_shcut'}){
	$to->{'PAPA_CLASS'} = '';
	$to->{'PAPA_ID'} = -1;
	$to->save();
    }
    
    my $str = $JDBI::dbh->prepare('DELETE FROM `arr_'.$o->myurl().'` WHERE num = ? LIMIT 1');
    $str->execute($eid);
    
    $o->sortT();
    
    return $to;
}

sub elem_moveto
{
    my $o = shift;
    my $enum = shift;
    my $place = shift;
    if(!$o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
    
    if($o->{'ID'} < 1){ return; }
    
    if($place eq ''){ $o->err_add('Новая позиция пуста.'); return; }
    if($place < 0){ $o->err_add('Новая позиция меньше 1.'); return; }
    if($place == $enum){ $o->err_add('Новая позиция рана старой.'); return; }
    if($place > $o->len()){ $o->err_add('Новая позиция больше или равна количеству элементов ('.$place.').'); return; }
    
    if(!$o->elem($enum)){ $o->err_add('Указанный элемент не существует ('.$enum.').'); return; }
    
    $o->sortT();
    
    my $str = $JDBI::dbh->prepare( 'UPDATE `arr_'.$o->myurl().'` SET num = num+1 WHERE num > '.$place );
    $str->execute();
    
    $str = $JDBI::dbh->prepare( 'UPDATE `arr_'.$o->myurl().'` SET `num` = ? WHERE `num` = ? LIMIT 1' );
    
    if($enum > $place){
	$str->execute($place+1,$enum+1);
    }else{
	$str->execute($place+1,$enum);
    }
    
    $o->sortT();
}


###################################################################################################
# Методы для оптимизации использования таблиц
###################################################################################################

sub create_array_table
{
    my $o = shift;
    
    my $sql = 'CREATE TABLE `arr_'.$o->myurl().'` ( '."\n";# IF NOT EXISTS
    $sql .= '`num` INT NOT NULL AUTO_INCREMENT , ';
    $sql .= '`ID` INT DEFAULT \'-1\' NOT NULL, ';
    $sql .= '`CLASS` VARCHAR(20) NOT NULL, ';
    $sql .= '`SHCUT` SMALLINT DEFAULT \'0\' NOT NULL, ';
    $sql .= 'INDEX ( `num` ) )';
    
    my $str = $JDBI::dbh->prepare($sql);
    $str->execute();
    
    $o->{'_isatable'} = 'yes';
}

sub is_array_table
{
    my $o = shift;
    
    if($o->{'ID'} < 1){ return 0; }
    
    if($o->{'_isatable'} eq 'yes'){ return 1; }
    if($o->{'_isatable'} eq 'no'){ return 0; }
    
    my $t;
    for $t ($JDBI::dbh->tables()){
	
	if( lc('`arr_'.$o->myurl().'`') eq lc($t) ){ $o->{'_isatable'} = 'yes'; return 1; }
	if( lc('arr_'.$o->myurl()) eq lc($t) ){ $o->{'_isatable'} = 'yes'; return 1; }
    }
    
    $o->{'_isatable'} = 'no';
    return 0;
}


###################################################################################################
# Методы для непосредственной работы с Базой Данных
###################################################################################################

sub len
{
    my $o = shift;
    
    if($o->{'ID'} < 1){ return 0; }
    if(!$o->is_array_table()){ return 0; }
    if(!$o->access('x')){ return 0; }
    
    my $str = $JDBI::dbh->prepare('SELECT COUNT(*) AS LEN FROM `arr_'.$o->myurl().'`');
    $str->execute();
    
    my $res = $str->fetchrow_hashref('NAME_uc');
    
    return $res->{'LEN'};
}

sub del
{
    my $o = shift;
    my $i;
    my $papa = $o->papa();
    if(!$papa){
	if(!$o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
    }else{
	if(!$papa->access('x')){ $o->err_add('У Вас нет разрешения изменять родителя этого элемента.'); return; }
    }
    if($o->{'ID'} < 1){ return; }
    
    my $len = $o->len();
    
    for($i=1;$i<=$len;$i++){ $o->elem_del(1); }
    
    if($o->is_array_table()){
	
	my $str = $JDBI::dbh->prepare('DROP TABLE `arr_'.$o->myurl().'`');
	$str->execute();
    }
    
    return $o->SUPER::del();
}

sub sortT
{
    my $o = shift;
    my($i,$str,$str2,$num,$table);
    
    if($o->{'ID'} < 1){ return; }
    if(!$o->is_array_table()){ return; }
    
    $table = 'arr_'.$o->myurl();
    
    $str = $JDBI::dbh->prepare( "ALTER TABLE `$table` ORDER BY `num`" );
    $str->execute();
    
    $str = $JDBI::dbh->prepare( "SELECT num FROM `$table`" );
    $str->execute();
    
    $str2 = $JDBI::dbh->prepare( "UPDATE `$table` SET `num` = ? WHERE `num` = ?" );
    
    $i = 1;
    while(($num) = $str->fetchrow_array()){
	
	$str2->execute($i,$num);
	$i++;
    }
}

###################################################################################################
# Методы для реализации наследования Perl
###################################################################################################

sub DESTROY
{
    my $o = shift;
    $o->SUPER::DESTROY();
}


###################################################################################################
# Дополнительные методы
###################################################################################################

sub type { return 'Array'; }



return 1;