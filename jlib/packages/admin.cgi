package admin;
use strict qw(subs vars);

my %mods = (
		'Сайт' => 'Dir1',
		'Пользователи' => 'UserGroupDir1'
	);
my $def_mod = 'Сайт';

my $do_list;

sub jchown
{
	my $url = eml::param('url');
	my $uid = eml::param('uid');
	my $obj = DBObject::url($url);
	my $tu;
	
	if(!$eml::g_group->{'root'}){ eml::err403('Trying chown, less $eml::g_group->{"root"}'); return; }
	
	$eml::sess{'admin_refresh_left'} = 0;

	if($uid){
		
		$uid =~ s/\D//g;
		
		$tu = User::new();
		$tu->load($uid);
		
		if($tu->{'ID'} < 1){ $obj->err_add('Указанный пользователь не существует!'); return; }
		
		$obj->{'OID'} = $uid;
		$obj->save();
		
		return;
	}

	$do_list = 0;

	my $nowu = User::new( $obj->{'OID'} );
	
	print 'Изменение владельца для элемента: <b>',$obj->name(),'</b><br>';
	print 'Текущий владелец элемента: <b>',$nowu->name(),'</b><br>';
	
	print '<br><br>Выберете нового владельца:<br><br>';
	
	my $count = 0;
	for $tu ($nowu->sel_where(' 1 ')){
		
		if($tu->{'ID'} == $nowu->{'ID'}){ next; }
		print '<img src="dot.gif" align="absmiddle"> <a href="?act=chown&url=',$url,'&uid=',$tu->{'ID'},'">',$tu->name(),'</a><br>';
		$count++;
	}
	
	if(!$count){ print '<center><b>Нет пользователей для отображения!</b></center>'; }
}

sub move2
{
	my $url = eml::param('url');
	my $uto = eml::param('to');
	my $enum = eml::param('enum');
	my $ref = eml::param('ref');
	
	my $from = DBObject::url($url);
	my $elem = $from->elem($enum);
	
	if($elem->{'_is_shcut'}){ $from->err_add('Меремещаемый элемен является ярлыком.'); return; }
	
	if($uto){
		
		my $to = DBObject::url($uto);
		
		if(!$to->elem_can_paste($elem)){ return; }
		
		if($ref){
			$elem = $from->elem($enum);
			$to->elem_paste_shcut($elem);
			
		}else{
			$elem = $from->elem_cut($enum);
			$to->elem_paste($elem);
		}
		
		return;
	}

	$eml::sess{'admin_refresh_left'} = 0;
	$do_list = 0;
	
	my $eclass = ref($elem);
	
	print 'Выберете раздел, в который переместить элемент: <b>',$elem->name(),'</b>.<br><br>';
	
	my $count = 0;
	
	my $c;
	for $c (@eml::dbos){
		
		if( index( ${$c.'::add'}, ' '.$eclass.' ') < 0 and ${$c.'::add'} ne '*' ){ next; }
		if( $c eq 'UserGroupRoot' ){ next; }
		
		my $tdir = &{$c.'::new'};
		my @dirs = $tdir->sel_where(' 1 ');
		my $d;
		for $d (@dirs){
			
			if($from->myurl() eq $d->myurl()){ next; }
			if($elem->myurl() eq $d->myurl()){ next; }
			
			print '<img src="dot.gif" align="absmiddle"><a href="?act=move2&url=',$from->myurl(),'&to=',$d->myurl(),'&enum=',$enum,'&ref=1"><img align=absmiddle border=0 src="shcut.gif"></a> <a href="?act=move2&url=',$from->myurl(),'&to=',$d->myurl(),'&enum=',$enum,'&ref=0">',$d->name(),'</a><br>';
			$count++;
		}
	}
	
	if(!$count){ print '<center><b>Нет разделов для отображения!</b></center>'; }
}

sub page_hrefs
{

	my $names = '';
	my $hrefs = '';
	
	print 'config.PageNames   = "',$names,'";',"\n";
	print 'config.PageValues  = "',$hrefs,'";',"\n";
}

sub action
{
	my $act = eml::param('act');
	my $url = eml::param('url');
	my $cn = eml::param('cname');
	my $enum = eml::param('enum');
	my $page = eml::param('page');
	
	
	my $w = DBObject::url($url);
	
	$do_list = 1;
	
	if($act){ $eml::sess{'admin_refresh_left'} = 1; }
	else{ return; }
	
	
	if($act eq 'edit'){
		
		my $tname = $w->name();
		$w->admin_edit();
		if($tname eq $w->name()){ $eml::sess{'admin_refresh_left'} = 0; }
	}
	
	if($act eq 'cre'){
		
		if(!eml::classOK($cn)){ return; }
		
		print STDERR 'BEGIN';
		
		my $to = &{$cn.'::new'}('cre');
		$to->admin_edit();
		
		$w->elem_paste($to);
	}
	
	if($act eq 'adde'){
		
		if(!eml::classOK($cn)){ return; }
		
		$eml::sess{'admin_refresh_left'} = 0;
		$do_list = 0;
		
		my $to = &{$cn.'::new'}();
		$to->admin_cre($w);
	}
	
	if($act eq 'dele'){ $w->elem_del($enum); }
	
	if($act eq 'eup'){ $w->elem_moveup($enum); }
	
	if($act eq 'edown'){ $w->elem_movedown($enum); }
	
	if($act eq 'move2'){ move2(); }
	
	if($act eq 'chown'){ jchown(); }
}

sub left_tree
{
	my $url = eml::param('url');
	my $to;
	
	if($url){
		$to = DBObject::url($url);
	}else{
		$to = Dir::new(1);
	}
	
	$to->admin_left();
}

sub tree
{
	my $url = eml::param('url') | eml::param('from');
	my $to;
	
	$to = DBObject::url($url);
	
	$to->admin_tree();
}

sub install
{
	my ($i,$j,$is,$count,@created);
	
	print '<center><h4>Создание таблиц.</h4></center><br>';
	
	$count = 0;
	for $i (@eml::dbos){
		
		$is = 0;
		
		for $j ($eml::dbh->tables()){
			
			if( lc('`dbo_'.$i.'`') eq lc($j) ){ $is = 1 }
			if( lc('dbo_'.$i) eq lc($j) ){ $is = 1 }
		}
		
		if(! $is){
			
			DBObject::creTABLE($i);
			push @created, $i;
			$count++;
		}
		
	}
	
	print '<br>';
	print $count?( 'Создано таблиц: <b>'.$count.'</b>' ):( 'Ниодной таблицы не было создано.' );
	print '<br>';
	
	print '<hr><br><center><h4>Услановка классов.</h4></center><br>';
	
	$count = 0;
	for $i (@created){
		
		if( defined &{$i.'::install'} ){
			
			print 'Установка объекта "<b>',$i,'</b>"<br>';
			&{$i.'::install'}($i);
			print '<br>';
			$count++;
		}
	}
	
	print '<br>';
	print $count?( 'Установлено объектов: <b>'.$count.'</b>' ):( 'Ниодного объекта не было установлено.' );
	print '<br>';
	
	print '<hr><br><center><h4>Создание структуры.</h4></center><br>';
	
	my $test = Dir::new(1);
	
	if($test->{'ID'} != 1){
	
		my $root = Dir::new('cre');
		$root->{'name'} = 'Главная страница';
		
		my $groot = UserGroupDir::new('cre');
		$groot->{'name'} = 'Группы пользователей';
		
		
		my $agroup = UserGroup::new('cre');
		$agroup->{'name'} = 'Администраторы';
		$agroup->{'cms'} = 1;
		$agroup->{'html'} = 1;
		$agroup->{'root'} = 1;
		
		my $admin = User::new('cre');
		$admin->{'login'} = 'admin';
		$admin->{'pas'} = $admin->{'login'};
		$admin->{'name'} = 'Администратор';
		
		$agroup->elem_paste($admin);
		$groot->elem_paste($agroup);
		
		print 'Имя http корня: "<b>',$root->{'name'},'</b>"<br>';
		print 'Имя user корня: "<b>',$groot->{'name'},'</b>"<br>';
		print 'Логин и пароль Администратора: "<b>',$admin->{'login'},'</b>"<br>';
		print 'Имя группы Администратора: "<b>',$agroup->{'name'},'</b>"<br>';
		
	}else{
		print 'Структура уже была создана.';
	}
	
	
	print '<br>';
}

sub modules
{
	my $m;
	my $sel_mod = eml::param('mod');
	my $uname;
	
	if($eml::g_user){ $uname = $eml::g_user->name() }else{ $uname = 'Вы не вошли в систему' }
	
	if(!$sel_mod){ $sel_mod = $def_mod }
	
	for $m (keys(%mods)){
		
		if($m eq $sel_mod){ print '<img src=bullet.gif align=absmiddle> <b>',$m,'</b><br>' }
		else{ print '<img src=bullet.gif align=absmiddle> <a onclick="" href="?mod=',$m,'">',$m,'</a><br>' }
	}
	
	print '
	<SCRIPT language="JavaScript">
	parent.document.frames.admin_left.location.href = "left.ehtml?url=',$mods{$sel_mod},'";
	parent.document.frames.admin_right.location.href = "right.ehtml?url=',$mods{$sel_mod},'";
	parent.document.all.module_div_it.innerHTML = "',$sel_mod,'";
	parent.document.all.user_div_it.innerHTML = "',$uname,'";
	</SCRIPT>
	';
	
}

sub list
{
	my $page = eml::param('page');
	my $url = eml::param('url');
	my $act = eml::param('act');
	
	if(!$do_list){ return; }
	
	my $w = DBObject::url($url);
	$w->save();
	$w->reload();
	$w->admin_view($page);
}

sub cms { if($eml::g_group->{'cms'} != 1){ eml::err403('$g_group->{"cms"} != 1'); } }

return 1;