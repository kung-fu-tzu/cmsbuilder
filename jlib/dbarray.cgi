package DBArray;
@ISA = 'DBObject';
use strict qw(subs vars);


###################################################################################################
# Следующие методы находятся в разработке
###################################################################################################



###################################################################################################
# Методы автоматизации администрирования
###################################################################################################

sub admin_left
{
	my $o = shift;
	
	if( ${ref($o).'::dont_list_me'} ){ return $o->SUPER::admin_left(); }
	
	my %node = $eml::cgi->cookie( 'dbi_'.ref($o).$o->{'ID'} );
	my $disp = $node{'s'} ? 'block' : 'none';
	my $pic  = $node{'s'} ? 'minus' : 'plus';
	
	print '<nobr><img class="icon" align="absmiddle" id="dbdot_'.ref($o).$o->{'ID'}.'" src="'.$pic.'.gif" onclick="ShowHide(dbi_'.ref($o).$o->{'ID'}.',dbdot_'.ref($o).$o->{'ID'}.')">',$o->admin_name(),'</nobr><br>',"\n";
	
	#print '<div id="id_'.ref($o).$o->{'ID'}.'"
	#onmouseover="return OnOver(id_'.ref($o).$o->{'ID'}.')"
	#onmouseout="return OnOut(id_'.ref($o).$o->{'ID'}.')"
	#onmouseup="return StopDrag(id_'.ref($o).$o->{'ID'}.')"
	#onmousedown="return StartDrag(id_'.ref($o).$o->{'ID'}.')"
	#style="Z-INDEX: 250; WIDTH: 10px; HEIGHT: 10px; BACKGROUND-COLOR: black"
	#></div>';
	#print "\n";
	print '<div id="dbi_'.ref($o).$o->{'ID'}.'" class="left_dir" style="DISPLAY: '.$disp.';">',"\n";
	my $to;
	for $to ($o->get_all()){
		
		$to->admin_left();
		
	}
	print '</div>',"\n";
}

sub admin_view
{
	my $o = shift;
	my $page = shift;
	my $e;
	my $i = 0;
	
	$o->SUPER::admin_view();
	
	my $len = $o->len();
	if(!$page){ $page = 0; }
	
	for $e ($o->get_page($page)){
		
		print '<br>';
		print '<a onclick="return doDel()" href="?class='.ref($o).'&ID='.$o->{ID}.'&enum='.$e->{'_ENUM'}.'&act=dele&page='.$page.'"><img border=0 src=x.gif></a>';
		
		if(${ref($o).'::pages_direction'}){
			if($e->{'_ENUM'} != 1){ print '<a href="?class='.ref($o).'&ID='.$o->{ID}.'&enum='.$e->{'_ENUM'}.'&act=eup&page='.$page.'"><img border=0 src=up.gif></a>'; }else{ print '<img src=nx.gif>' }
			if($e->{'_ENUM'} != $len){ print '<a href="?class='.ref($o).'&ID='.$o->{ID}.'&enum='.$e->{'_ENUM'}.'&act=edown&page='.$page.'"><img border=0 src=down.gif></a>'; }else{ print '<img src=nx.gif>' }
		}else{
			if($e->{'_ENUM'} != $len){ print '<a href="?class='.ref($o).'&ID='.$o->{ID}.'&enum='.$e->{'_ENUM'}.'&act=edown&page='.$page.'"><img border=0 src=up.gif></a>'; }else{ print '<img src=nx.gif>' }
			if($e->{'_ENUM'} != 1){ print '<a href="?class='.ref($o).'&ID='.$o->{ID}.'&enum='.$e->{'_ENUM'}.'&act=eup&page='.$page.'"><img border=0 src=down.gif></a>'; }else{ print '<img src=nx.gif>' }
		}
		
		print '<a href="move2.ehtml?from='.ref($o).$o->{'ID'}.'&enum='.$e->{'_ENUM'}.'"><img border=0 src=move2.gif></a>';
		print "\n",'&nbsp;&nbsp;',"\n";
		#print '<a href="?class='.ref($e).'&ID='.$e->{'ID'}.'">',$e->name(),'</a>';
		print $e->admin_name();
		print "\n";
	}
	
	
	if($o->pages() > 1){
		
		print '<br><br><center>';	
		print '<table class="pages_table" cellspacing="0" cellpadding="0"><tr>';
		
		my $p;
		for($p=0;$p<$o->pages();$p++){
			
			if($p == $page){ print '<td width=20 align=center height=20 bgcolor="#ff7300"><b>'.($p+1).'</b></td>'; }
			else{ print '<td width=20 align=center height=20><a href="?class='.ref($o).'&ID='.$o->{'ID'}.'&page='.$p.'">'.($p+1).'</a><td>' }
			
		}
		
		print '</tr></table>';
		print '</center>';
		
	}
	
	my $c;

	print '<form action="?">';
	print '<input type="hidden" name="ID" value="',$o->{ID},'">',"\n";
	print '<input type="hidden" name="act" value="adde">',"\n";
	print '<input type="hidden" name="class" value="',ref($o),'">',"\n";

	print '<select name=cname><OPTION selected></OPTION>';
	for $c (@eml::dbos){
		
		if( index( ${ref($o).'::add'}, ' '.$c.' ') < 0 ){ next; }
		print "<OPTION value='$c'>${$c.'::name'}</OPTION>";
	}
	print '</select><input type=submit value="Добавить"></form>';
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
	
	if( ${ref($o).'::pages_direction'} )
	    { @ret = $o->get_page_inc($page) }
	else{ @ret = $o->get_page_dec($page) }
	
	return @ret;
}

sub get_all
{
	my $o = shift;
	my $page = shift;
	my @ret;
	
	if( ${ref($o).'::pages_direction'} )
	    { @ret = $o->get_all_inc($page) }
	else{ @ret = $o->get_all_dec($page) }
	
	return @ret;
}

sub get_all_inc
{
	my $o = shift;
	my $page = shift;
	$page =~ s/\D//g;
	
	my $to;
	my @ret;
	my $i = 1;
	
	
	while($to = $o->elem($i)){
		
		$to->{'_ENUM'} = $i;
		
		push @ret, $to;
		$i++;
	}
	
	return @ret;
}

sub get_all_dec
{
	my $o = shift;
	my $page = shift;
	$page =~ s/\D//g;
	
	my $to;
	my @ret;
	my $i = $o->len();
	
	
	while($to = $o->elem($i)){
		
		$to->{'_ENUM'} = $i;
		
		push @ret, $to;
		$i--;
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
		
		$to->{'_ENUM'} = $i;
		
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
		
		$to->{'_ENUM'} = $i;
		
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
	
	my $ob = $o->elem_cut($eid);
	$ob->del();
	$ob = '';
}

sub elem_moveup
{
	my $o = shift;
	my $num = shift;
	
	$o->elem_moveto($num,$num-2);
}

sub elem_movedown
{
	my $o = shift;
	my $num = shift;
	
	$o->elem_moveto($num,$num+1);
}

sub elem_paste
{
	my $o = shift;
	my $po = shift;
	
	if($o->{ID} < 0){ return; }
	
	$o->elem_paste_ref($po);
	
	$po->{PAPA_ID} = $o->{ID};
	$po->{PAPA_CLASS} = ref($o);
	
	$po->save();
}


###################################################################################################
# Методы для непосредственной работы с массивом
###################################################################################################

sub elem_paste_ref
{
	my $o = shift;
	my $po = shift;
	
	if($o->{ID} < 0){ return; }
	if(!$o->is_array_table()){ $o->create_array_table();  }
	
	my $cname = ref($po);
	if( index( ${ref($o).'::add'}, ' '.$cname.' ') < 0 ){ eml::err505('Trying to add element with classname "'.$cname.'", to array "'.ref($o).'"'); }
	
	my $str = $eml::dbh->prepare('INSERT INTO `arr_'.ref($o).'_'.$o->{ID}.'` (ID,CLASS) VALUES (?,?)');
	$str->execute($po->{ID},ref($po));
	
	$o->sortT();
}

sub elem
{
	my $o = shift;
	my $eid = shift;
	
	if($o->{ID} < 0){ return undef; }
	if(!$o->is_array_table()){ return undef; }
	
	my $str = $eml::dbh->prepare('SELECT * FROM `arr_'.ref($o).'_'.$o->{ID}.'` WHERE num = ? LIMIT 1');
	$str->execute($eid);
	
	my $res = $str->fetchrow_hashref('NAME_uc');
	
	if(!$res->{'CLASS'}){ return undef; }
	
	return &{ $res->{'CLASS'}.'::new' }($res->{ID});
}

sub elem_cut
{
	my $o = shift;
	my $eid = shift;
	
	if($o->{ID} < 0){ return; }
	
	my $to = $o->elem($eid);
	if(!$to){ return undef; }
	
	$to->{'PAPA_CLASS'} = '';
	$to->{'PAPA_ID'} = -1;
	$to->save();
	
	my $str = $eml::dbh->prepare('DELETE FROM `arr_'.ref($o).'_'.$o->{ID}.'` WHERE num = ? LIMIT 1');
	$str->execute($eid);
	
	$o->sortT();
	
	return $to;
}

sub elem_moveto
{
	my $o = shift;
	my $enum = shift;
	my $place = shift;
	
	if($o->{ID} < 0){ return; }
	
	if($place eq ''){ eml::err505('elem_moveto: Новая позиция пуста'); }
	if($place < 0){ eml::err505('elem_moveto: Новая позиция меньше 1'); }
	if($place == $enum){ eml::err505('elem_moveto: Новая позиция рана старой'); }
	if($place > $o->len()){ eml::err505('elem_moveto: Новая позиция больше или равна длине массива'); }
	
	if(! $o->elem($enum)){ return; }
	
	$o->sortT();
	
	my $str = $eml::dbh->prepare( 'UPDATE `arr_'.ref($o).'_'.$o->{ID}.'` SET num = num+1 WHERE num > '.$place );
	$str->execute();
	
	$str = $eml::dbh->prepare( 'UPDATE `arr_'.ref($o).'_'.$o->{ID}.'` SET `num` = ? WHERE `num` = ? LIMIT 1' );
	
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
	
	my $sql = 'CREATE TABLE `arr_'.ref($o).'_'.$o->{'ID'}.'` ( '."\n";# IF NOT EXISTS
	$sql .= '`num` INT NOT NULL AUTO_INCREMENT , ';
	$sql .= '`ID` INT DEFAULT \'-1\' NOT NULL, ';
	$sql .= '`CLASS` VARCHAR(20) NOT NULL, ';
	$sql .= 'INDEX ( `num` ) )';

	my $str = $eml::dbh->prepare($sql);
	$str->execute();
	
	$o->{'_isatable'} = 'yes';
}

sub is_array_table
{
	my $o = shift;
	
	if($o->{ID} < 0){ return 0; }
	
	if($o->{'_isatable'} eq 'yes'){ return 1; }
	if($o->{'_isatable'} eq 'no'){ return 0; }
	
	
	my $t;
	
	for $t ($eml::dbh->tables()){
		
		if( lc('`arr_'.ref($o).'_'.$o->{'ID'}.'`') eq lc($t) ){ $o->{'_isatable'} = 'yes'; return 1; }
		if( lc('arr_'.ref($o).'_'.$o->{'ID'}) eq lc($t) ){ $o->{'_isatable'} = 'yes'; return 1; }
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

	if($o->{ID} < 0){ return 0; }
	if(!$o->is_array_table()){ return 0; }

	my $str = $eml::dbh->prepare('SELECT COUNT(*) AS LEN FROM `arr_'.ref($o).'_'.$o->{ID}.'`');
	$str->execute();
	
	my $res = $str->fetchrow_hashref('NAME_uc');
	
	return $res->{'LEN'};
}

sub del
{
	my $o = shift;
	my $i;
	
	if($o->{ID} < 0){ return; }
	
	my $len = $o->len();

	for($i=1;$i<=$len;$i++){
		
		$o->elem_del(1);
		
	}
	
	if(!$o->is_array_table()){ $o->SUPER::del(); return; }
	
	my $str = $eml::dbh->prepare('DROP TABLE `arr_'.ref($o).'_'.$o->{ID}.'`');
	$str->execute();
	
	$o->SUPER::del();
}

sub sortT
{
	my $o = shift;
	my($i,$str,$str2,$num,$table);
	
	if($o->{ID} < 0){ return; }
	if(!$o->is_array_table()){ return; }
	
	$table = 'arr_'.ref($o).'_'.$o->{ID};
	
	$str = $eml::dbh->prepare( "ALTER TABLE `$table` ORDER BY `num`" );
	$str->execute();
	
	$str = $eml::dbh->prepare( "SELECT num FROM `$table`" );
	$str->execute();
	
	$str2 = $eml::dbh->prepare( "UPDATE `$table` SET `num` = ? WHERE `num` = ?" );
	
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

sub type { return 'DBArray'; }



return 1;