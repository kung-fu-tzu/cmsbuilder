package JDBI::Array;
use strict qw(subs vars);
our @ISA = 'JDBI::Object';
use JIO;
use CGI 'param';


###################################################################################################
# Следующие методы находятся в разработке
###################################################################################################

sub update_ats_cts
{
	my $o = shift;
	my($str,$r,@cls,$oldid,$c,$sql,$tblc,$tbl);
	
	unless($o->len()){ return; }
	
	$oldid = $o->{'ID'};
	$o->{'ID'} .= 'copy';
	$tblc = $o->myurl();
	$o->create_array_table();
	$o->{ID} = $oldid;
	
	$tbl = $o->myurl();
	
	$str = $JDBI::dbh->prepare('SELECT DISTINCT CLASS FROM `arr_'.$o->myurl().'`');
	$str->execute();
	
	while(($r) = $str->fetchrow_array()){ push(@cls,$r); }
	
	for $c (@cls){
		
		$sql = '
		INSERT  INTO arr_'.$tblc.'( CLASS, ID, ATS, CTS ) 
		SELECT  "'.$c.'" AS CLASS, dbo_'.$c.'.ID, dbo_'.$c.'.ATS, dbo_'.$c.'.CTS
		FROM dbo_'.$c.', arr_'.$tbl.'
		WHERE arr_'.$tbl.'.ID = dbo_'.$c.'.ID AND arr_'.$tbl.'.CLASS =  "'.$c.'"
		';
		$JDBI::dbh->do($sql);
		#print $sql;
	}
	
	$JDBI::dbh->do('DELETE FROM `arr_'.$tbl.'`');
	$JDBI::dbh->do('INSERT INTO `arr_'.$tbl.'` SELECT * FROM `arr_'.$tblc.'`');
	$JDBI::dbh->do('DROP TABLE `arr_'.$tblc.'`');
}


###################################################################################################
# Методы автоматизации администрирования
###################################################################################################

sub admin_cmenu_for_son
{
	my $o = shift;
	my $son = shift;
	
	
	if($o->access('w')){
		
		print 'elem_add(JHR());';
		print 'elem_add(JMIDelete("Удалить","right.ehtml?url=',$o->myurl(),'&act=dele&enum=',$son->enum(),'&page=0"));';
		print 'elem_add(JMIHref("Ярлык...","right.ehtml?url=',$o->myurl(),'&act=mkshcut&enum=',$son->enum(),'"));';
		print 'elem_add(JMIHref("Переместить...","right.ehtml?url='.$o->myurl().'&act=move2&enum='.$son->enum().'"));';
		
	}
}

sub admin_cmenu_for_self
{
	my $o = shift;
	
	my $ret = $o->SUPER::admin_cmenu_for_self(@_);
	
	print 'elem_add(JHR());';
	print 'smenu = JMenu();';
	print 'with( smenu ){';
	print 'elem_add(JTitle("Сортировать"));';
	if($o->len()){
		print 'elem_add(JMIHref("Обратить","right.ehtml?url=',$o->myurl(),'&act=arr_sort&by=reverse"));';
		print 'elem_add(JMIHref("По типу","right.ehtml?url=',$o->myurl(),'&act=arr_sort&by=class"));';
		print 'elem_add(JMIHref("Создан","right.ehtml?url=',$o->myurl(),'&act=arr_sort&by=cts"));';
		print 'elem_add(JMIHref("Изменён","right.ehtml?url=',$o->myurl(),'&act=arr_sort&by=ats"));';
		print 'elem_add(JHR());';
	}
	print 'elem_add(JMIHref("По ID","right.ehtml?url=',$o->myurl(),'&act=arr_sort&by=id"));';
	print 'elem_add(JMIHref("Починить","right.ehtml?url=',$o->myurl(),'&act=arr_sort&by=num"));';
	print '}';
	print 'smenu_i = elem_add(JMISubMenu("Сортировать",smenu));';
	
	return $ret;
}

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
	for $to ($o->get_interval(1,$JConfig::admin_max_left)){ $to->admin_left() }
	
	if($o->len() > $JConfig::admin_max_left){ print '<nobr><font style="CURSOR: default" title="Количество элементов, отображаемых в левой панели, ограничено. Вы можете продолжать добавлять элементы, они будут доступны в правой панели - постранично." color="#ff7300" size=1>Элементов слишком много...</font></nobr><br>',"\n"; }
	print '</div>',"\n";
}

sub admin_view
{
	my $o = shift;
	my $page = shift;
	my($n1,$n2) = (0,0);
	my $i = 0;
	my($e,$up,$down);
	
	$o->SUPER::admin_view();
	
	if(!$o->access('r')){ return; }
	
	print '<p class="hr">';
	print '
	<script language="JavaScript">
	if(CMS_HaveParent()) document.write(\'',$o->admin_name(),' - \');
	</script>
	';
	print ' Список вложенных элементов:</p>';
	
	my $len = $o->len();
	if(!$page){ $page = 0; }
	
	for $e ($o->get_page($page)){
		
		unless($n1){ $n1 = $e->enum(); }
		$n2 = $e->enum();
		
		if($o->access('w')){
			$e->admin_arrayline($o,$page);
		}else{
			print '<img align="absmiddle" src="img/nx.gif">' x 2;
		}
		
		print '<img align="absmiddle" src="img/nx.gif">';
		print $e->admin_name(),'<br>';
		print '<hr id="drag_line_',$e->enum(),'" onmouseover="DnD_Line_OnMouseOver(',$e->enum(),',this)" onmouseout="DnD_Line_OnMouseOut(',$e->enum(),',this)" style="DISPLAY: none" class="drag_line">';
		print "\n";
		$i++;
	}
	
	print '
	<script language="JavaScript">
	drag_line_n1 = ',$n1,';
	drag_line_n2 = ',$n2,';
	drag_href_url = "',$o->myurl(),'";
	</script>
	';
	
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
	
	$o->admin_add();
	
	print '<br><br>';
}

sub admin_add
{
	my $o = shift;
	my($c,$count);
	
	unless($o->access('a')){ return; }
	
	print '
	<br><br>
	<table><tr>
	<td valign="top">Добавить:</td><td>';
	
	for $c (@JDBI::classes){
		
		unless($o->elem_can_add($c)){ next; }
		if($c eq 'ShortCut'){ next; }
		print $c->admin_cname('','right.ehtml?url='.$o->myurl().'&act=adde&cname='.$c),'<br>';
		$count++;
	}
	
	unless($count){ print 'Нет классов'; };
	
	print '</td></tr></table><br>';
}

###################################################################################################
# Методы для работы со страницами
###################################################################################################

sub pages
{
	my $o = shift;
	my $len = $o->len();
	
	unless($o->{'onpage'}){ $o->{'onpage'} = $JConfig::array_def_on_page; }
	
	$len /= $o->{'onpage'};
	if($len != int($len)){ $len = int($len); $len++; }
	
	return $len;
}

sub get_all
{
	my $o = shift;
	my $where = shift;
	
	return $o->get_interval(1,$o->len(),$where);
}

sub get_all_class
{
	my $o = shift;
	
	return $o->get_all(JDBI::Array::get_class_wheresql(@_));
}

sub get_page
{
	my $o = shift;
	my $page = shift;
	my $where = shift;
	$page =~ s/\D//g;
	
	if($page < 0){ return (); }
	
	my $ps = $o->pages();
	if($page >= $ps){ $page = $ps - 1; }
	
	unless($o->{'onpage'}){ $o->{'onpage'} = $JConfig::array_def_on_page; }
	
	my $beg = $o->{'onpage'} * $page + 1;
	
	return $o->get_interval($beg,$beg+$o->{'onpage'}-1,$where);
}

sub get_page_class
{
	my $o = shift;
	my $page = shift;
	
	return $o->get_page($page,JDBI::Array::get_class_wheresql(@_));
}

sub get_class_wheresql
{
	my($where,$cl);
	
	for $cl (@_){
		unless(JDBI::classOK($cl)){ next; }
		$where .= ' CLASS = "'.$cl.'" OR';
	}
	
	if($where){
		$where =~ s/OR$//;
		$where = ' ( '.$where.' ) ';
	}
	
	return $where;
}

###################################################################################################
# Дополнительные методы для работы с элементами
###################################################################################################

sub elem_del
{
	my $o = shift;
	my $eid = shift;
	unless($o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
	my $obj = $o->elem($eid);
	unless($obj){ $o->err_add($eid.$o->myurl()); return; }
	unless($obj->access('w')){ $o->err_add('У Вас нет разрешения изменять удаляемый элемент.'); return; }
	
	$obj = $o->elem_cut($eid);
	$obj->del();
	
	$obj = '';
}

sub elem_moveup
{
	my $o = shift;
	my $num = shift;
	unless($o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
	
	$o->elem_moveto($num,$num-2);
}

sub elem_movedown
{
	my $o = shift;
	my $num = shift;
	unless($o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
	
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
	$po->on_Array_elem_paste($o);
}


###################################################################################################
# Основные методы для работы с элементами массива
###################################################################################################

sub get_interval
{
	my $o = shift;
	my $beg = shift;
	my $end = shift;
	my $where = shift;
	
	if($end < $beg or $beg < 1){ return (); }
	unless($o->access('x')){ $o->err_add('У Вас нет разрешения просматривать этот элемент.'); return (); }
	unless($o->is_array_table()){ return (); }
	
	my($sql,$ref,$str,$str2,@oar,$to);
	
	$sql = 'SELECT CLASS,ID,num FROM `arr_'.$o->myurl().'` WHERE num >= ? '.($where?' AND '.$where:'').' LIMIT '.($end-$beg+1);
	
	$str = $JDBI::dbh->prepare($sql);
	$str->execute($beg,@_);
	
	while($ref = $str->fetchrow_arrayref()){
		
		$to = $ref->[0]->new($ref->[1]);
		
		$to->{'_ENUM'} = $ref->[2];
		$to->{'_ARRAY'} = ref($o);
		
		if(!$to->{'ID'}){
			
			#print '[hello',$to->{'ID'},'-',$o->myurl(),']';
			$JDBI::dbh->do('DELETE FROM `arr_'.$o->myurl().'` WHERE num = ? LIMIT 1',undef,$ref->[2]);
			sess()->{'admin_refresh_left'} = 1;
			next;
		}
		
		next unless $to->access('r');
		
		push @oar,$to;
	}
	#print $sql;
	return @oar;
}

sub elem_paste_ref
{
	my $o = shift;
	my $po = shift;
	if(!$o->access('a')){ $o->err_add('У Вас нет разрешения добавлять в этот элемент.'); return; }
	
	if($o->{'ID'} < 1){ return; }
	if($po->{'ID'} < 1){ return; }
	unless($o->is_array_table()){ $o->create_array_table();  }
	
	unless($o->elem_can_paste($po)){ JIO::err505('Trying to add element with classname "'.ref($po).'", to array "'.ref($o).'"'); }
	
	my $str;
	
	if( ${ref($o).'::pages_direction'} ){
		$JDBI::dbh->do('INSERT INTO `arr_'.$o->myurl().'` (ID,CLASS) VALUES (?,?)',undef,$po->{'ID'},ref($po));
	}else{
		$JDBI::dbh->do('UPDATE `arr_'.$o->myurl().'` SET num = num + 1');
		$JDBI::dbh->do('INSERT INTO `arr_'.$o->myurl().'` (num,ID,CLASS) VALUES (1,?,?)',undef,$po->{'ID'},ref($po));
	}
	
	$o->sortT();
}

sub elem_can_paste
{
	my $o = shift;
	my $po = shift;
	if(!$o->access('a')){ return 0; }
	if($o->myurl() eq $po->myurl()){ return 0; }
	if($po->papa() and $po->papa()->myurl() eq $o->myurl()){ return 0; }
	
	my $papa = $o;
	my $i;
	while($papa = $papa->papa()){
		if($papa->myurl() eq $po->myurl()){ return 0; }
		$i++;
		if($i > 50){ return 0; } # Есть залупленные объекты
	}
	
	
	if($o->elem_can_add(ref($po))){
		if(ref($po) eq 'ShortCut'){ return $o->elem_can_add( ref($po->shcut_obj()) ); }
		return 1;
	}else{
		return 0;
	}
}

sub elem_can_add
{
	my $o = shift;
	my $c = shift;
	my $myc = ref($o)?ref($o):$o;
	
	if( ${$myc.'::add'} eq '*' ){ return 1; }
	if( index( ${$myc.'::add'}, ' '.$c.' ') >= 0 ){ return 1; }
	
	return 0;
}

sub elem_tell_enum
{
	my $o = shift;
	my $to = shift;
	
	if(!$o->access('x')){ $o->err_add('У Вас нет разрешения просматривать этот элемент.'); return 0; }
	
	if($o->{'ID'} < 1){ return 0; }
	unless($o->is_array_table()){ return 0; }
	
	my $str = $JDBI::dbh->prepare('SELECT num FROM `arr_'.$o->myurl().'` WHERE CLASS = ? AND ID = ? LIMIT 1');
	$str->execute(ref($to),$to->{'ID'});
	
	my ($res) = $str->fetchrow_array();
	
	return $res;
}

sub elem
{
	my $o = shift;
	my $enum = shift;
	
	my ($to) = $o->get_interval($enum,$enum);
	
	return $to;
}

sub elem_cut
{
	my $o = shift;
	my $eid = shift;
	unless($o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
	
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
	
	$to->on_Array_elem_cut($o);
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
	if($place == $enum){ $o->err_add('Новая позиция равна старой.'); return; }
	if($place > $o->len()){ $o->err_add('Новая позиция больше или равна количеству элементов ('.$place.').'); return; }
	
	my $elem = $o->elem($enum);
	unless($elem){ $o->err_add('Указанный элемент не существует ('.$enum.').'); return; }
	
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
	
	$elem->on_Array_elem_moveto($enum,$place);
}


###################################################################################################
# Методы для оптимизации использования таблиц
###################################################################################################

sub create_array_table
{
	my $o = shift;
	
	my $sql = 'CREATE TABLE `arr_'.$o->myurl().'` ( '
	. '`num` INT NOT NULL AUTO_INCREMENT , '
	. '`ID` INT DEFAULT \'-1\' NOT NULL, '
	. '`CLASS` VARCHAR(20) NOT NULL, '
	#. '`SHCUT` SMALLINT DEFAULT \'0\' NOT NULL, '
	. '`ATS` DATETIME NOT NULL, '
	. '`CTS` DATETIME NOT NULL, '
	. 'INDEX ( `num` ) )';
	
	my $str = $JDBI::dbh->prepare($sql);
	$str->execute();
	
	$o->{'_isatable'} = 'yes';
}

sub is_array_table
{
	my $o = shift;
	
	if($o->{'ID'} < 1){ return 0; }
	if(exists $o->{'_isatable'}){ return $o->{'_isatable'}; }
	
	my $t;
	for $t ($JDBI::dbh->tables()){
		
		if( index($t,'arr_'.$o->myurl()) >= 0){ $o->{'_isatable'} = 1; return 1; }
	}
	
	$o->{'_isatable'} = 0;
	return 0;
}


###################################################################################################
# Методы для непосредственной работы с Базой Данных
###################################################################################################

sub len
{
	my $o = shift;
	my $where = shift;
	
	if($o->{'ID'} < 1){ return 0; }
	unless($o->is_array_table()){ return 0; }
	unless($o->access('x') and $o->access('r')){ return 0; }
	
	my $str = $JDBI::dbh->prepare('SELECT COUNT(*) AS LEN FROM `arr_'.$o->myurl().'`'.($where?' WHERE '.$where:''));
	$str->execute();
	
	my ($res) = $str->fetchrow_array();
	
	return $res;
}

sub len_class
{
	my $o = shift;
	return $o->len(JDBI::Array::get_class_wheresql(@_));
}

sub del
{
	my $o = shift;
	my $i;
	my $papa = $o->papa();
	if(!$papa){
		unless($o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
	}else{
		unless($papa->access('x') and $papa->access('w')){ $o->err_add('У Вас нет разрешения изменять родителя этого элемента.'); return; }
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
	my $by = shift;
	my($i,$table);
	
	if($o->{'ID'} < 1){ return; }
	if(!$o->is_array_table()){ return; }
	$by =~ s/\W//;
	unless($by){ $by = 'num'; }
	
	$table = 'arr_'.$o->myurl();
	
	$JDBI::dbh->do('ALTER TABLE `'.$table.'` ORDER BY `'.$by.'`;');
	$JDBI::dbh->do('SET @cnt:=0;');
	$JDBI::dbh->do('UPDATE `'.$table.'` SET num = @cnt:=@cnt+1;');
}

sub reverse
{
	my $o = shift;
	my $len = $o->len();
	
	$JDBI::dbh->do('UPDATE `arr_'.$o->myurl().'` SET num = '.$len.' - num + 1');
	
	$o->sortT();
}


###################################################################################################
# Дополнительные методы
###################################################################################################

sub type { return 'Array'; }



return 1;