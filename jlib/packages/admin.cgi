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
	
	if($act eq 'edit'){
		$w->load( $id );
		$w->admin_edit();
		
		print 'Изменения успешно внесены.';
	}
	
	if($act eq 'del'){
		$w->load( $id );
		$w->del();
		
		eml::unflush();
		print "Location: ".$prev."?class=$class&page=$page\n";
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
		print 'Location: '.$prev.'?class='.$class.'&ID='.$w->{ID}.'&page='.$page;
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
		print 'Location: '.$prev.'?class='.$class.'&ID='.$w->{ID}.'&page='.$page;
		print "\n\n";
		exit();
	}
	
	if($act eq 'eup'){
		
		$w->load( $id );
		$w->elem_moveup($eid);
		
		eml::unflush();
		print 'Location: '.$prev.'?class='.$class.'&ID='.$w->{ID}."&page=$page\n";
		print "\n";
		exit();
	}
	
	if($act eq 'edown'){
		
		$w->load( $id );
		$w->elem_movedown($eid);
		
		eml::unflush();
		print 'Location: '.$prev.'?class='.$class.'&ID='.$w->{ID}."&page=$page\n";
		print "\n";
		exit();
	}
	
	
}

sub left_obj_view
{
	my $obj = shift;
	
	if($obj->type() eq 'DBObject'){ print '<img hspace="5" vspace="2" align="absmiddle" src="dot.gif">',$obj->admin_name(),'<br>'; return; }
	#if($obj->len() == 0){ print '<img hspace="5" vspace="2" align="absmiddle" src="dot.gif">',$obj->admin_name(),'<br>'; return; }
	
	
	my %node = $co->cookie( 'dbi_'.ref($obj).$obj->{'ID'} );
	my $disp = $node{'s'} ? 'block' : 'none';
	my $pic  = $node{'s'} ? 'minus' : 'plus';
	
	print '<div>','<img hspace="5" vspace="2" align="absmiddle" id="dbdot_'.ref($obj).$obj->{'ID'}.'" src="'.$pic.'.gif" onclick="ShowHide(dbi_'.ref($obj).$obj->{'ID'}.',dbdot_'.ref($obj).$obj->{'ID'}.')">',$obj->admin_name(),'</div>';
	print '<div id="dbi_'.ref($obj).$obj->{'ID'}.'" class="left_dir" style="DISPLAY: '.$disp.';">';
	my $to;
	for $to ($obj->get_all()){
		
		left_obj_view($to);
		
	}
	print '</div>';
	
}

sub left_tree
{
	my $obj = Dir::new(1);
	
	$co = new CGI;
	
	print '<div class="left_all">';
	left_obj_view($obj);
	print '</div>';
}

sub tree
{
	my $id = eml::param('ID');
	
	if(! $id){ return; }
	if($id eq 'cre'){ return; }
	
	print '<br>';
	$w->load($id);
	$w->admin_tree();
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
		print "<a href=?class=".$class."&ID=cre>Создать</a><br><br>";
	}
}


return 1;