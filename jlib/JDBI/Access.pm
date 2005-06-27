# (с) Леонов П.А., 2005

package JDBI::Access;
use strict qw(subs vars);
use JDBI;
use CGI ('param');

our %rpcs =
(
	'access_chmod'	=> [],
);

our ($AC_READ,$AC_WRITE,$AC_ADD,$AC_CHMOD,$AC_EXEC) = (1,2,4,8,16);
our $_2BYTE = 65535;
our $_4BYTE = 4294967295;

our %access_types =
(
	$AC_READ => 'Чтение',
	$AC_WRITE => 'Редактирование',
	$AC_ADD => 'Добавление&nbsp;элементов',
	$AC_CHMOD => 'Смена&nbsp;разрешений',
	$AC_EXEC => 'Доступ&nbsp;ко&nbsp;вложенным'
);

our %type2bin =
(
	'r' => $AC_READ,
	'w' => $AC_WRITE,
	'a' => $AC_ADD,
	'c' => $AC_CHMOD,
	'x' => $AC_EXEC
);


###################################################################################################
# Методы поддерживающие RPC
###################################################################################################

sub access_chmod
{
	my $o = shift;
	my $r = shift;
	
	my $chact = $r->{'chact'};
	
	unless($o->access('c')){ $o->err_add('У Вас нет прав менять разрешения этому элементу.'); return; }
	
	$o->{'_dont_list'} = 1;
	JIO::sess()->{'admin_refresh_left'} = 0;
	
	if($chact eq 'edit')
	{
		my $old_code = $o->{'_access_code'};
		
		$o->access_edit();
		
		$o->{'_access_geted'} = 0;
		$o->access('r');
		
		if($o->{'_access_code'} ne $old_code){ JIO::sess()->{'admin_refresh_left'} = 1; }
		
		if($r->{'submit'} eq 'OK'){ $o->{'_dont_list'} = 0; return; }
	}
	
	if($chact eq 'addlist'){ $o->access_add_list(); return; }
	if($chact eq 'add'){ $o->access_add($r->{'memb'}); }
	if($chact eq 'del'){ $o->access_del($r->{'memb'}); }
	
	$o->access_view();
}


###################################################################################################
# Методы реализации разделения доступа
###################################################################################################

sub access_memb_name
{
	my $memb = shift;
	
	if($memb eq 'all'){ return 'Все'; }
	if($memb eq 'owner'){ return 'Владелец'; }
	
	return JDBI::url($memb)->name();
}

sub access_add
{
	my $o = shift;
	my $m = shift;
	my $code = shift;
	my($res,$str);
	
	unless(access_memb_name($m)){ $o->err_add('Неверно указан элемент.'); return; }
	
	$str = $JDBI::dbh->prepare('SELECT ID FROM `access` WHERE memb = ? AND url = ?');
	$str->execute($m,$o->myurl());
	if($str->fetchrow_hashref()){ $o->err_add('Такой элемент уже есть.'); return; }
	
	unless($code)
	{
		if($m eq 'all'){ $code = $o->{'_access_code'} }
		elsif($m eq 'owner' and $o->{'OID'} == $JDBI::user->{'ID'}){ $code = $o->{'_access_code'} }
		elsif($m eq $JDBI::user->myurl()){ $code = $o->{'_access_code'} }
		elsif($m eq $JDBI::group->myurl()){ $code = $o->{'_access_code'} }
	}
	
	if(!$code){ $code = 0; }
	
	$str = $JDBI::dbh->prepare('INSERT INTO `access` (url,memb,code) VALUES (?,?,?)');
	$str->execute($o->myurl(),$m,$code);
}

sub access_del
{
	my $o = shift;
	my $m = shift;
	my($res,$str,$have);
	
	unless(access_memb_name($m)){ $o->err_add('Неверно указан элемент.'); return; }
	
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
	my($res,$str,%membs,$tg,$tu,$to,$count);
	
	$str = $JDBI::dbh->prepare('SELECT memb,code FROM `access` WHERE url = ?');
	$str->execute($o->myurl());
	while( $res = $str->fetchrow_hashref('NAME_lc') ){ $membs{$res->{'memb'}} = 1; }
	
	print 'Добавление разрешений для элемента: <b>',$o->admin_name(),'</b><br><br>';
	print '<b>Специальные:</b><br><br>';
	
	$count = 0;
	unless($membs{'all'}){ print '<a href="?url=',$o->myurl(),'&act=access_chmod&chact=add&memb=all">Все</a><br>'; $count++; }
	unless($membs{'owner'}){ print '<a href="?url=',$o->myurl(),'&act=access_chmod&chact=add&memb=owner">Владелец</a> (сейчас: ',$o->owner->admin_name(),')<br>'; $count++; }
	unless($count){ print 'Нет элементов для отображения.'; }
	
	print '<br><br><b>Группы:</b><br><br>';
	
	$count = 0;
	for $tg (UserGroup->sel_where(' 1 '))
	{
		unless($membs{$tg->myurl()}){ print $tg->admin_cname( $tg->name(),'?url='.$o->myurl().'&act=access_chmod&chact=add&memb='.$tg->myurl() ),'<br>'; $count++; }
	}
	if(!$count){ print 'Нет групп для отображения.'; }
	
	print '<br><br><b>Пользователи:</b><br><br>';
	
	$count = 0;
	for $tu (User->sel_where(' 1 '))
	{
		unless($membs{$tu->myurl()}){ print $tu->admin_cname( $tu->name(),'?url='.$o->myurl().'&act=access_chmod&chact=add&memb='.$tu->myurl() ),'<br>'; $count++; }
	}
	
	unless($count){ print 'Нет пользователей для отображения.'; }
}

sub access_view
{
	my $o = shift;
	my($res,$str,$tm,$type,@all,$i);
	
	$str = $JDBI::dbh->prepare('SELECT memb,code FROM `access` WHERE url = ?');
	$str->execute($o->myurl());
	while( $res = $str->fetchrow_hashref('NAME_lc') ){ push(@all, $res); }
	
	if($o->err_is())
	{
		print '<table align="center"><tr><td class="mes_table"><font color="red">Возникла ошибка!</font><br><br>';
		$o->err_print();
		print '</td></tr></table><br>';
	}
	
	if($#all < 0){ print '<center>Для этого элемента разрешения не определены.<br><br><a href="?url=',$o->myurl(),'&act=access_chmod&chact=addlist">Добавить...</a></center>'; return; }
	
	print '<center>Изменение разрешений для элемента: <b>',$o->name(),'</b><br><br>';
	print '<SELECT size="5" id="uarea" onchange="SelMemb()" class="ainput" style="WIDTH: 300px">';
	
	for $res ( @all ){ print '<OPTION value="',$res->{'memb'},'">&nbsp;&nbsp;',access_memb_name($res->{'memb'}),'</OPTION>'; }
	
	print '</SELECT><br>';
	
	print '<table align="center" style="WIDTH: 290px"><tr><td align="left"><img src="img/x.gif" onclick="if(changed){ alert(\'Сначала сохраните!\'); return; } DelMemb()"></td><td align="right"><a onclick="if(changed){ alert(\'Сначала сохраните!\'); return false}" href="?url=',$o->myurl(),'&act=access_chmod&chact=addlist">Добавить...</a></td></tr></table>';
	
	print '
	<form method="POST" action="?">
	<input type="hidden" name="act" value="access_chmod">
	<input type="hidden" name="chact" value="edit">
	<input type="hidden" name="url" value="',$o->myurl(),'">
	';
	
	for $res ( @all )
	{
		print '<div style="DISPLAY: none" id="div_',$res->{'memb'},'"><table class="ainput" style="WIDTH: 300px">';
		
		print '<br><center>',access_memb_name($res->{'memb'}),':</center><br>';
		
		for $type (keys(%access_types))
		{
			print '<tr><td>&nbsp;&nbsp;<b>',$access_types{$type},'</b></td>';
			print '<td>&nbsp;<input onclick="OnCh()" type="checkbox" ';
			if( ($res->{'code'}*1) & $type ){ print ' CHECKED '; };
			print ' name="',$res->{'memb'},'_',$type,'"></td></tr>';
		}
		
		print '</table></div>';
	}
	
	print '
	<br><input type="submit" name="submit" value="OK"> <input type="submit" name="submit" value="Применить">
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
	
	function SelMemb()
	{
		if(div_sel) div_sel.style.display = "none";
		div_ids[uarea.selectedIndex].style.display = "block";
		div_sel = div_ids[uarea.selectedIndex];
	}
	
	function DelMemb()
	{
		if(!doDel()) return;
		var memb = uarea.item(uarea.selectedIndex).value;
		
		location.href = "?url=',$o->myurl(),'&act=access_chmod&chact=del&memb=" + memb;
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
	
	for $res ( @all )
	{
		$membs{$res->{'memb'}} = 0;
		for $type (keys(%access_types))
		{
			$box = param($res->{'memb'}.'_'.$type);
			#print $membs{$res->{'memb'}} ,'|', ($box?$type:0), '=', $membs{$res->{'memb'}} | ($box?$type:0),'<br>';
			$membs{$res->{'memb'}} |= ($box?$type:0);
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
	
	unless( $o->{'_access_code'} & $AC_READ )
	{
		$o->{'_access_code'} &= $AC_CHMOD ^ $_2BYTE;
		$o->{'_access_code'} &= $AC_WRITE ^ $_2BYTE;
	}
	
	$papa = $o->papa();
	
	unless($papa){ return; }
	unless($papa->access('x')){ $o->{'_access_code'} = 0; }
}

sub access_load
{
	my $o = shift;
	my (%membs,$str,$res,$g,$u);
	
	$o->{'_access_code'} = '';
	
	($g,$u) = ($JDBI::group->myurl(),$JDBI::user->myurl());
	
	$str = $JDBI::dbh->prepare('SELECT memb,code FROM `access` WHERE url = ? and memb in (?,?,?,?)');
	$str->execute($o->myurl(),'all','owner',$g,$u);
	
	
	while( $res = $str->fetchrow_hashref('NAME_lc') ){ $membs{$res->{'memb'}} = $res->{'code'}; }
	
	if(exists $membs{$u}){ $o->{'_access_code'} = $membs{$u}; return; }
	if(exists $membs{'owner'} and $JDBI::user->{'ID'} == $o->{'OID'}){ $o->{'_access_code'} = $membs{'owner'}; return; }
	
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
	
	if(length($type) != 1){ return 0 }
	if(!$JConfig::access_on_e){ return 1 }
	if($JDBI::group->{'root'}){ return 1 }
	
	$o->access_get();
	
	if( $o->{'_access_code'} & $type2bin{$type} ){ return 1; }
	
	return 0;
}

sub access_print
{
	my $o = shift;
	my $type;
	my @out;
	
	for $type (keys(%type2bin))
	{
		if($o->access($type)){ push(@out,$access_types{$type2bin{$type}}) }
	}
	
	if($#out < 0){ return 'Нет' }
	return join(', ',@out);
}

sub ochown
{
	my $o = shift;
	my $uid = shift;
	
	if(!$JDBI::group->{'root'}){ return 0; }
	if($uid < 1){ return 0; }
	$o->{'OID'} = $uid;
	
	return $uid;
}


1;