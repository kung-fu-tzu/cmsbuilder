package JDBI::Object;

###################################################################################################
# Методы реализации разделения доступа
###################################################################################################

use strict qw(subs vars);
use vars '%access_types';


%access_types = (
		'r' => 'Чтение',
		'w' => 'Редактирование',
		'a' => 'Добавление&nbsp;элементов',
		'c' => 'Смена&nbsp;разрешений',
		'x' => 'Доступ&nbsp;ко&nbsp;вложенным'
		);

#@access_words = qw/all owner/;

sub access_memb_name
{
	my $memb = shift;
	
	if($memb eq 'all'){ return 'Все'; }
	if($memb eq 'owner'){ return 'Владелец'; }
	
	my $tm = DBObject::url($memb);
	return $tm->name();
}

sub access_add
{
	my $o = shift;
	my $m = shift;
	my($res,$str,$have,$code);
	
	if(!access_memb_name($m)){ $o->err_add('Неверно указан элемент.'); return; }
	
	$have = 0;
	$str = $JDBI::dbh->prepare('SELECT ID FROM `access` WHERE memb = ? AND url = ?');
	$str->execute($m,$o->myurl());
	while( $res = $str->fetchrow_hashref('NAME_lc') ){ $have = 1; }
	if($have){ $o->err_add('Такой элемент уже есть.'); return; }
	
	$code = '';
	if($m eq 'all'){ $code = $o->{'_access_code'} }
	if($m eq 'owner' and $o->{'OID'} == $JDBI::g_user->{'ID'}){ $code = $o->{'_access_code'} }
	if($m eq $JDBI::g_user->myurl()){ $code = $o->{'_access_code'} }
	if($m eq $JDBI::g_group->myurl()){ $code = $o->{'_access_code'} }
	
	$str = $JDBI::dbh->prepare('INSERT INTO `access` (url,memb,code) VALUES (?,?,?)');
	$str->execute($o->myurl(),$m,$code);
}

sub access_del
{
	my $o = shift;
	my $m = shift;
	my($res,$str,$have);
	
	if(!access_memb_name($m)){ $o->err_add('Неверно указан элемент.'); return; }
	
	$have = 0;
	$str = $JDBI::dbh->prepare('SELECT ID FROM `access` WHERE memb = ? AND url = ?');
	$str->execute($m,$o->myurl());
	while( $res = $str->fetchrow_hashref('NAME_lc') ){ $have = 1; }
	if(!$have){ $o->err_add('Такого элемента нет.'); return; }
	
	$str = $JDBI::dbh->prepare('DELETE FROM `access` WHERE url = ? AND memb = ?');
	$str->execute($o->myurl(),$m);
}

sub access_add_list
{
	my $o = shift;
	my($res,$str,%membs,$tg,$tu,$to,$count,$owner_name);
	
	$str = $JDBI::dbh->prepare('SELECT memb,code FROM `access` WHERE url = ?');
	$str->execute($o->myurl());
	while( $res = $str->fetchrow_hashref('NAME_lc') ){ $membs{$res->{'memb'}} = 1; }
	
	print 'Добавление разрешений для элемента: <b>',$o->name(),'</b><br><br>';
	print '<b>Специальные:</b><br><br>';
	
	$count = 0;
	$owner_name = User::new($o->{'OID'})->name();
	if(!$membs{'all'}){ print '<a href="?url=',$o->myurl(),'&act=chmod&chact=add&memb=all">Все</a><br>'; $count++; }
	if(!$membs{'owner'}){ print '<a href="?url=',$o->myurl(),'&act=chmod&chact=add&memb=owner">Владелец</a> (сейчас: ',$owner_name,')<br>'; $count++; }
	if(!$count){ print 'Нет элементов для отображения.'; }
	
	print '<br><br><b>Группы:</b><br><br>';
	
	$count = 0;
	$to = UserGroup::new();	
	for $tg ($to->sel_where(' 1 ')){
		
		if(!$membs{$tg->myurl()}){ print '<a href="?url=',$o->myurl(),'&act=chmod&chact=add&memb=',$tg->myurl(),'">',$tg->name(),'</a><br>'; $count++; }
	}
	if(!$count){ print 'Нет групп для отображения.'; }
	
	print '<br><br><b>Пользователи:</b><br><br>';
	
	$count = 0;
	$to = User::new();	
	for $tu ($to->sel_where(' 1 ')){
		
		if(!$membs{$tu->myurl()}){ print '<a href="?url=',$o->myurl(),'&act=chmod&chact=add&memb=',$tu->myurl(),'">',$tu->name(),'</a><br>'; $count++; }
	}
	if(!$count){ print 'Нет пользователей для отображения.'; }
}

sub access_view
{
	my $o = shift;
	my($res,$str,$tm,$type,@all,$i);
	
	$str = $JDBI::dbh->prepare('SELECT memb,code FROM `access` WHERE url = ?');
	$str->execute($o->myurl());
	while( $res = $str->fetchrow_hashref('NAME_lc') ){ push(@all, $res); }
	
	if($o->err_is()){
		
		print '<table align="center"><tr><td class="mes_table"><font color="red">Возникла ошибка!</font><br><br>';
		$o->err_print();
		print '</td></tr></table><br>';
	}
	
	if($#all < 0){ print '<center>Для этого элемента разрешения не определены.<br><br><a href="?url=',$o->myurl(),'&act=chmod&chact=addlist">Добавить...</a></center>'; return; }
	
	print '<center>Изменение разрешений для элемента: <b>',$o->name(),'</b><br><br>';
	print '<SELECT size="5" id="uarea" onchange="SelMemb()" class="ainput" style="WIDTH: 300px">';
	
	for $res ( @all ){ print '<OPTION value="',$res->{'memb'},'">&nbsp;&nbsp;',access_memb_name($res->{'memb'}),'</OPTION>'; }
	
	print '</SELECT><br>';
	
	print '<table align="center" style="WIDTH: 290px"><tr><td align="left"><img src="x_on.gif" onclick="if(changed){ alert(\'Сначала сохраните!\'); return; } DelMemb()"></td><td align="right"><a onclick="if(changed){ alert(\'Сначала сохраните!\'); return false}" href="?url=',$o->myurl(),'&act=chmod&chact=addlist">Добавить...</a></td></tr></table>';
	
	print '
		<form method="POST" action="?">
		<input type="hidden" name="act" value="chmod">
		<input type="hidden" name="chact" value="edit">
		<input type="hidden" name="url" value="',$o->myurl(),'">
	';
	
	for $res ( @all ){
		
		print '<div style="DISPLAY: none" id="div_',$res->{'memb'},'"><table class="ainput" style="WIDTH: 300px">';
		
		print '<br><center>',access_memb_name($res->{'memb'}),':</center><br>';
		
		for $type (keys(%access_types)){
			print '<tr><td>&nbsp;&nbsp;<b>',$access_types{$type},'</b></td>';
			print '<td>&nbsp;<input onclick="OnCh()" type="checkbox" ';
			if( index($res->{'code'},$type) >= 0 ){ print ' CHECKED '; };
			print ' name="',$res->{'memb'},'_',$type,'"></td></tr>';
		}
		
		print '</table></div>';
	}
	
	print '
		<br><input type="submit" value="Применить">
		</form></center>
	';
	
	
	
	print '
	
	<SCRIPT LANGUAGE=javascript>
	var div_ids = new Array;
	var div_sel;
	var changed = 0;
	
	';
	
	$i = 0;
	for $res ( @all ){ print 'div_ids[',$i,'] = div_',$res->{'memb'},';'; $i++; }
	
	print '
	
	function OnCh(){ changed = 1; }
	
	function SelMemb(){
		
		if(div_sel) div_sel.style.display = "none";
		div_ids[uarea.selectedIndex].style.display = "block";
		div_sel = div_ids[uarea.selectedIndex];
		
	}
	
	function DelMemb(){
		
		if(!doDel()) return;
		var memb = uarea.item(uarea.selectedIndex).value;
		
		location.href = "?url=',$o->myurl(),'&act=chmod&chact=del&memb=" + memb;
	}
	
	uarea.selectedIndex = 0;
	div_ids[0].style.display = "block";
	div_sel = div_ids[0];
	</SCRIPT>
	
	';
}

sub access_edit
{
	my $o = shift;
	my($res,$str,@all,$box,%membs,$type,$m);
	
	$str = $JDBI::dbh->prepare('SELECT memb,code FROM `access` WHERE url = ?');
	$str->execute($o->myurl());
	while( $res = $str->fetchrow_hashref('NAME_lc') ){ push(@all, $res); }
	
	if($#all < 0){ $o->err_add('Перед редактированием не было добавлено ни одного пользователя.'); return; }
	
	for $res ( @all ){
		
		for $type (keys(%access_types)){
			$box = JDBI::param($res->{'memb'}.'_'.$type);
			$membs{$res->{'memb'}} .= ($box?$type:'');
		}
	}
	
	$str = $JDBI::dbh->prepare('UPDATE `access` SET code = ? WHERE memb = ? AND url = ?');
	
	for $m (keys(%membs)){ $str->execute($membs{$m},$m,$o->myurl()); }
	
	$o->{'_print'} = 'Разрешения успешно изменены.';
	
}

sub access_set
{
	my $o = shift;
	my $code = shift;
	
	$o->{'_access_geted'} = 1;
	
	$o->{'_access_code'} = $code;
}

sub access_get
{
	my $o = shift;
	if($o->{'_access_geted'}){ return; }
	my($type,$code,$papa);
	
	$o->{'_access_geted'} = 1;
	$o->access_load();
	
	
	$papa = $o->papa();
	
	if(!$papa){ return; }
	if(!$papa->access('x')){ $o->{'_access_code'} = ''; }
	if(!$papa->access('x')){ $o->{'_access_code'} .= 'x' }
}

sub access_load
{
	my $o = shift;
	my (%membs,$str,$res,$g,$u);
	
	$o->{'_access_code'} = '';
	
	#print STDERR $JDBI::g_user,$o->myurl();
	($g,$u) = ($JDBI::g_group->myurl(),$JDBI::g_user->myurl());
	
	$str = $JDBI::dbh->prepare('SELECT memb,code FROM `access` WHERE url = ? and memb in (?,?,?,?)');
	$str->execute($o->myurl(),'all','owner',$g,$u);
	
	
	while( $res = $str->fetchrow_hashref('NAME_lc') ){ $membs{$res->{'memb'}} = $res->{'code'}; }
	
	if(exists $membs{$u}){ $o->{'_access_code'} = $membs{$u}; return; }
	if(exists $membs{'owner'} and $JDBI::g_user->{'ID'} == $o->{'OID'}){ $o->{'_access_code'} = $membs{'owner'}; return; }
	
	if(exists $membs{$g}){ $o->{'_access_code'} = $membs{$g}; return; }
	if(exists $membs{'all'}){ $o->{'_access_code'} = $membs{'all'}; return; }
	
	my $papa = $o->papa();
	
	if(!$papa){ return; }
	$papa->access_get();
	
	$o->{'_access_code'} = $papa->{'_access_code'};
	
	return;
}

sub access
{
	my $o = shift;
	my $type = shift;
	my $is = 0;
	my $papa;
	
	return 1;
	
	if(length($type) != 1){ return 0 }
	if($JDBI::g_group->{'root'}){ return 1 }
	
	$o->access_get();
	
	if( index($o->{'_access_code'},$type) < 0 ){ return 0; }
	
	if($type eq 'c' and !$o->access('r')){ return 0; }
	if($type eq 'w' and !$o->access('r')){ return 0; }
	
	return 1;
}

sub access_print
{
	my $o = shift;
	my $type;
	my @out;
	
	for $type (keys(%access_types)){
		
		if($o->access($type)){ push(@out,$access_types{$type}) }
	}
	
	if($#out < 0){ return 'Нет' }
	return join(', ',@out);
}

sub access_creTABLE
{
	my $sql = 'CREATE TABLE IF NOT EXISTS `access` ( '."\n";
	$sql .= '`ID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY , ';
	$sql .= '`url` VARCHAR(50) NOT NULL, ';
	$sql .= '`memb` VARCHAR(50) DEFAULT \'\' NOT NULL, ';
	$sql .= '`code` VARCHAR(20) DEFAULT \'\' NOT NULL, ';
	$sql .= 'INDEX ( `memb` ), INDEX ( `url` ) )';

	my $str = $JDBI::dbh->prepare($sql);
	$str->execute();
}

sub ochown
{
	my $o = shift;
	my $uid = shift;
	
	if(!$JDBI::g_group->{'root'}){ return 0; }
	if($uid < 1){ return 0; }
	$o->{'OID'} = $uid;
	
	return $uid;
}



1;

