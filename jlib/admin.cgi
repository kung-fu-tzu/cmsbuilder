package admin;
use strict qw(subs vars);

my %mods = (
		'Сайт' => 'Dir1',
		'Пользователи' => 'UserGroupDir1'
	);
my $def_mod = 'Сайт';

my $do_list;

sub jchmod
{
	my $url = eml::param('url');
	my $chact = eml::param('chact');
	my $obj = DBObject::url($url);
	
	if(!$obj->access('c')){ $obj->err_add('У Вас нет прав менять разрешения этому элементу.'); return; }
	
	$do_list = 0;
	$eml::sess{'admin_refresh_left'} = 0;
	
	
	if($chact eq 'edit'){
		
		my $old_code = $obj->{'_access_code'};
		
		$obj->access_edit();
		$do_list = 1;
		
		$obj->{'_access_geted'} = 0;
		$obj->access('r');
		
		if($obj->{'_access_code'} ne $old_code){ $eml::sess{'admin_refresh_left'} = 1; }
		
		return;
	}
	if($chact eq 'addlist'){ $obj->access_add_list(); return; }
	if($chact eq 'add'){ $obj->access_add(eml::param('memb')); }
	if($chact eq 'del'){ $obj->access_del(eml::param('memb')); }
	
	$obj->access_view();
}

sub jchown
{
	my $url = eml::param('url');
	my $uid = eml::param('uid');
	my $obj = DBObject::url($url);
	my $tu;
	
	if(!$eml::g_group->{'root'}){ $obj->err_add('У Вас нет прав менять владельца элементам.'); return; }
	
	$eml::sess{'admin_refresh_left'} = 0;

	if($uid){
		
		$uid =~ s/\D//g;
		
		$tu = User::new();
		$tu->load($uid);
		
		if($tu->{'ID'} < 1){ $obj->err_add('Указанный пользователь не существует.'); return; }
		
		$obj->ochown($uid);
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
	
	if(!$count){ print '<center><b>Нет пользователей для отображения.</b></center>'; }
}

sub move2
{
	my $url = eml::param('url');
	my $uto = eml::param('to');
	my $enum = eml::param('enum');
	my $ref = eml::param('ref');
	
	my $from = DBObject::url($url);
	my $elem = $from->elem($enum);
	
	if(!$from->access('w')){ $from->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
	if(!$elem->access('w')){ $from->err_add('У Вас нет разрешения изменять перемещаемый элемент.'); return; }
	if($elem->{'_is_shcut'}){ $from->err_add('Перемещаемый элемент является ярлыком.'); return; }
	
	if($uto){
		
		my $to = DBObject::url($uto);
		if(!$to->access('a')){ $from->err_add('У Вас нет разрешения добавлять в элемент назначения.'); return; }
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
			if(!$d->access('a')){ next; }
			
			print '<img src="dot.gif" align="absmiddle"><a href="?act=move2&url=',$from->myurl(),'&to=',$d->myurl(),'&enum=',$enum,'&ref=1"><img align=absmiddle border=0 src="shcut.gif"></a> <a href="?act=move2&url=',$from->myurl(),'&to=',$d->myurl(),'&enum=',$enum,'&ref=0">',$d->name(),'</a><br>';
			$count++;
		}
	}
	
	if(!$count){ print '<center><b>Нет разделов для отображения.</b></center>'; }
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
		
		#print STDERR 'BEGIN';
		
		if(!$w->access('a')){ $w->err_add('У Вас нет разрешения добавлять в этот элемент.'); return; }
		
		my $to = &{$cn.'::new'}('cre');
		$to->admin_edit();
		
		$w->elem_paste($to);
	}
	
	if($act eq 'adde'){
		
		if(!eml::classOK($cn)){ return; }
		
		if(!$w->access('a')){ $w->err_add('У Вас нет разрешения добавлять в этот элемент.'); return; }
		
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
	
	if($act eq 'chmod'){ jchmod(); }
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
	my ($i,$j,$is,$count,@created,$reinstall);
	
	if(!$eml::g_group->{'root'}){ eml::err403('Trying to (re)install, less $eml::g_group->{"root"}'); return; }
	
	$reinstall = eml::param('re');
	
	print '<center><h4>Создание таблиц.</h4></center><br>';
	
	if($reinstall){
		
		my $str;
		for $i ($eml::dbh->tables()){
			
			$str = $eml::dbh->prepare('DROP TABLE IF EXISTS '.$i);
			$str->execute();
		}
	}
	
	
	DBObject::access_creTABLE();
	
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
		
		
		#################################
		
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
		
		##################################
		
		
		my $ggroup = UserGroup::new('cre');
		$ggroup->{'name'} = 'Гости';
		$ggroup->{'cms'} = 0;
		$ggroup->{'html'} = 0;
		$ggroup->{'root'} = 0;
		
		my $guest = User::new('cre');
		$guest->{'login'} = '';
		$guest->{'pas'} = $guest->{'login'};
		$guest->{'name'} = 'Гость';
		
		$ggroup->elem_paste($guest);
		
		#################################
		
		$groot->elem_paste($agroup);
		$groot->elem_paste($ggroup);
		
		print 'Имя http корня: "<b>',$root->{'name'},'</b>"<br>';
		print 'Имя user корня: "<b>',$groot->{'name'},'</b>"<br>';
		print 'Логин и пароль Администратора: "<b>',$admin->{'login'},'</b>"<br>';
		print 'Имя группы Администратора: "<b>',$agroup->{'name'},'</b>"<br>';
		print 'Логин и пароль Гостя: "<b>',$guest->{'login'},'</b>"<br>';
		print 'Имя группы Гостя: "<b>',$ggroup->{'name'},'</b>"<br>';
		
		$admin->{'sid'} = $eml::sess{'JLogin_sid'};
		#$admin->save();
		#JLogin::login($admin->{'login'},$admin->{'pas'});
		
	}else{
		print 'Структура уже была создана.';
	}
	
	print '<br>';
}

sub modules
{
	my $m;
	my $sel_mod = eml::param('mod');
	my($uname,$to);
	
	$uname = $eml::g_group->name().' / '.$eml::g_user->name();
	
	if(!$sel_mod){ $sel_mod = $def_mod }
	
	for $m (keys(%mods)){
		$to = DBObject::url($mods{$m});
		if(!$to->access('x')){ next; }
		
		if($m eq $sel_mod){ print '<img src=bullet.gif align=absmiddle> <b>',$m,'</b><br>' }
		else{ print '<img src=bullet.gif align=absmiddle> <a onclick="" href="?mod=',$m,'">',$m,'</a><br>' }
	}
	
	print '
	<SCRIPT language="JavaScript">
	parent.document.frames.admin_left.location.href = "left.ehtml?url=',$mods{$sel_mod},'";
	parent.document.frames.admin_right.location.href = "right.ehtml?url=',$mods{$sel_mod},'";
	parent.document.all.module_div_it.innerHTML = "',$sel_mod,'";
	parent.document.all.user_div_it.innerHTML = "',$uname,'";
	parent.document.all.site_name_it.innerHTML = "http://',$ENV{'HTTP_HOST'},'/";
	</SCRIPT>
	';
	#my $key;
	#for $key (keys %ENV ){	print "$key = $ENV{$key}<br>"; }
	
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
	if(!$w->access('r')){ $w->err_add('У вас нет разрешений для просмотра этого элемента.'); }
	$w->admin_view($page);
}

sub cms { if($eml::g_group->{'cms'} != 1){ eml::err403('$g_group->{"cms"} != 1'); } }

return 1;