package admin;
use strict qw(subs vars);

my $w;
my $co;

my $class;

sub init
{
	my ($cl);
	
	$cl = eml::param('class');
	
	if( !eml::classOK($cl) ){ $cl = $eml::dbos[0]; }
	
	if($w){ $w->clear(); }
	$w = &{ $cl.'::new' };
	$class = $cl;
}

sub types
{
	print $eml::path;
	print "<TABLE style='HEIGHT: 100%;' height='100%' cellSpacing=0 cellPadding=0><tr>";
	print "<td width=150></td><td width=1 bgcolor=#D2D9DF></td>";
	
	my $c;
	my $dbo;
	my $nm;
	
	for $dbo (@eml::dbos) { 
		
		$c = '';
		if($dbo eq $class){ $c = ' class=mtypes_s '; }
		else{ $c = ' class=mtypes '; }
		
		$nm = ${$dbo.'::name'};
		
		print "<td $c>";
		print "<a href=?class=$dbo>$nm</a> "; 
		print "</td><td width=1 bgcolor=#D2D9DF></td>";
	}
	
	print "</tr></TABLE>";
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
		print 'Location: '.$prev.'?class='.$class.'&ID='.$w->{ID}.'&page='.$page.'&ac='.$rnd;
		print "\n\n";
		exit();
	}
	
	if($act eq 'moveto'){
		
		#$w->addelem($cn);
		#$w->load( $id );
		#my $rto = Dir::new($rid);
		
		#my $to = $w->cut_elem($eid);
		
		#$rto->paste_elem($to);
		
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

sub left_tree1
{
	my $http = Dir::new(1);
	$http->admin_left();
	
	print '<br><hr><br>';
	
	my $users = UserGroupDir::new(1);
	$users->admin_left();

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
	
	my $admin = User::new('cre');
	$admin->{'login'} = 'admin';
	$admin->{'pas'} = $admin->{'login'};
	$admin->{'name'} = 'Администратор';
	$admin->{'gid'} = 0;
	
	$agroup->elem_paste($admin);
	$groot->elem_paste($agroup);
	
	print 'Имя http корня: "<b>',$root->{'name'},'</b>"<br>';
	print 'Имя user корня: "<b>',$groot->{'name'},'</b>"<br>';
	print 'Логин и пароль Администратора: "<b>',$admin->{'login'},'</b>"<br>';
	print 'Имя группы Администратора: "<b>',$agroup->{'name'},'</b>"<br>';
	
	print '<br>';
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