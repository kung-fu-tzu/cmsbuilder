package admin;
use strict qw(subs vars);

my $w;
my $co;

my $class;

my %mods = (
		'Сайт' => 'Dir1',
		'Пользователи' => 'UserGroupDir1'
	);
my $def_mod = 'Сайт';

sub init
{
	my ($cl);
	
	$cl = eml::param('class');
	
	if( !eml::classOK($cl) ){ $cl = $eml::dbos[0]; }
	
	if($w){ $w->clear(); }
	$w = &{ $cl.'::new' };
	$class = $cl;
}

sub move2
{
	my $ufrom = eml::param('from');
	my $uto = eml::param('to');
	my $enum = eml::param('enum');
	
	my $from = DBObject::url($ufrom);
	my $elem;
	
	if($uto){
		
		my $to = DBObject::url($uto);
		
		$elem = $from->elem_cut($enum);
		$to->elem_paste($elem);
		
		$eml::sess{'admin_refresh_left'} = 1;
		
		print '<script language="JavaScript">location.href = "right.ehtml?ID=',$from->{'ID'},'&class=',ref($from),'"</script>';
		return;
	}
	
	$elem  = $from->elem($enum);
	my $eclass = ref($elem);
	
	print '<center>Выберете раздел, в который переместить элемент: <b>',$elem->name(),'</b>.</center><br>';
	
	my $count = 0;
	
	my $c;
	for $c (@eml::dbos){
		
		if( index( ${$c.'::add'}, ' '.$eclass.' ') < 0 ){ next; }
		if( $c eq 'UserGroupRoot' ){ next; }
		
		my $tdir = &{$c.'::new'};
		my @dirs = $tdir->sel_where(' 1 ');
		my $d;
		for $d (@dirs){
			
			if($from->myurl() eq $d->myurl()){ next; }
			
			print '<img src=dot.gif align=absmiddle> <a href="?from=',$from->myurl(),'&to=',$d->myurl(),'&enum=',$enum,'">',$d->name(),'</a><br>';
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
	my $id = eml::param('ID');
	my $cn = eml::param('cname');
	my $eid = eml::param('enum');
	my $rid = eml::param('rid');
	my $page = eml::param('page');
	
	my $prev = $ENV{'HTTP_REFERER'};
	$prev =~ s/\?.*//g;
	
	if($act){ $eml::sess{'admin_refresh_left'} = 1; }
	srand();
	my $rnd = rand();
	$rnd =~ s/\D//g;
	
	if($act eq 'edit'){
		$w->load( $id );
		$w->admin_edit();
		
	}
	
	if($act eq 'del'){
		$w->load( $id );
		$w->del();
		
		eml::unflush();
		print "Location: ".$prev."?class=$class&page=$page&ac=$rnd\n";
		print "\n";
		exit();
	}
	
	if($act eq 'adde'){
		
		if($cn eq ''){ return; }
		
		my $to = &{$cn.'::new'}('cre');
		
		$w->load( $id );
		$w->elem_paste($to);
		
		if( ${ref($w).'::pages_direction'} ){ $page = $w->pages()-1; }else{ $page = 0; }
		
		eml::unflush();
		#print 'Location: '.$prev.'?class='.$class.'&ID='.$w->{ID}.'&page='.$page.'&ac='.$rnd;
		print 'Location: '.$prev.'?class='.$cn.'&ID='.$to->{ID}.'&ac='.$rnd;
		print "\n\n";
		exit();
	}
	
	if($act eq 'dele'){
		
		$w->load( $id );
		$w->elem_del($eid);
		
		eml::unflush();
		print 'Location: ',$prev,'?class=',$class,'&ID=',$w->{ID},'&page=',$page,'&ac=',$rnd;
		print "\n\n";
		exit();
	}
	
	if($act eq 'eup'){
		
		$w->load( $id );
		$w->elem_moveup($eid);
		
		eml::unflush();
		print 'Location: ',$prev,'?class=',$class,'&ID=',$w->{ID},'&page=',$page,'&ac=',$rnd;
		print "\n\n";
		exit();
	}
	
	if($act eq 'edown'){
		
		$w->load( $id );
		$w->elem_movedown($eid);
		
		eml::unflush();
		print 'Location: ',$prev,'?class=',$class,'&ID=',$w->{ID},'&page=',$page,'&ac=',$rnd;
		print "\n\n";
		exit();
	}
	
	
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
	my $id = eml::param('ID');
	
	if(! $id){ return; }
	if($id eq 'cre'){ return; }
	
	$w->load($id);
	$w->admin_tree();
}

sub install
{
	my ($i,$j,$is,$count);
	
	print '<center><h4>Создание таблиц.</h4></center><br>';
	
	for $i (@eml::dbos){
		
		$is = 0;
		
		for $j ($eml::dbh->tables()){
			
			if( lc('`dbo_'.$i.'`') eq lc($j) ){ $is = 1 }
		}
		
		if(! $is){
			
			my $to = &{ $i.'::new' };
			$to->creTABLE();
			$count++;
			undef $to;
			
		}
		
	}
	
	print '<br>';
	print $count?( 'Создано таблиц: <b>'.$count.'</b>' ):( 'Ниодной таблицы не было создано.' );
	print '<br>';
	
	print '<hr><br><center><h4>Создание структуры.</h4></center><br>';
	
	my $root = Dir::new('cre');
	$root->{'name'} = 'Главная страница';
	
	my $groot = UserGroupDir::new('cre');
	$groot->{'name'} = 'Группы пользователей';

	
	my $agroup = UserGroup::new('cre');
	$agroup->{'name'} = 'Администраторы';
	$agroup->{'adminka'} = 1;
	
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
	
	my $agroup2 = UserGroupRoot::new('cre');
	$agroup2->{'name'} = 'root';
	$agroup2->{'adminka'} = 1;
	
	my $admin2 = User::new('cre');
	$admin2->{'login'} = 'root';
	$admin2->{'pas'} = 'gogogosuperuser';
	$admin2->{'name'} = 'root';
	
	$agroup2->elem_paste($admin2);
	
	print '<br>';
}

sub modules
{
	my $m;
	my $sel_mod = eml::param('mod');
	
	if(!$sel_mod){ $sel_mod = $def_mod }
	
	for $m (keys(%mods)){
		
		print '<img src=bullet.gif align=absmiddle> <a onclick="" href="?mod=',$m,'">',$m,'</a><br>';
	}
	
	my ($class,$id) = DBObject::url2classid($mods{$sel_mod});
	
	print '
	<SCRIPT language="JavaScript">
	parent.document.frames.admin_left.location.href = "left.ehtml?url=',$mods{$sel_mod},'";
	parent.document.frames.admin_right.location.href = "right.ehtml?ID=',$id,'&class=',$class,'";
	parent.document.all.module_div_it.innerHTML = "',$sel_mod,'";
	</SCRIPT>
	';
	
}

sub list
{
	my $id = eml::param('ID');
	my $page = eml::param('page');
	
	if($id){
		
		$w->load($id);
		$w->admin_view($page);
		
	}else{
		
		print '<br>';
		$w->admin_list('',$page);
		print '<br>';
		
		print '<hr>';
		print "<a href=?class=".$class."&ID=cre>Создать</a>";
	}
}

sub w { return $w; }

return 1;