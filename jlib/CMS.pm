package CMS;
use strict qw(subs vars);
use CGI ('param');
use JDBI;
use JIO;

my %mods = (
	'����' => 'HttpRoot1',
	'������������' => 'UserRoot1'
    );
my $def_mod = '����';
my $do_list;

sub jchmod
{
    my $url = param('url');
    my $chact = param('chact');
    my $obj = url($url);
    
    if(!$obj->access('c')){ $obj->err_add('� ��� ��� ���� ������ ���������� ����� ��������.'); return; }
    
    $do_list = 0;
    sess()->{'admin_refresh_left'} = 0;
    
    
    if($chact eq 'edit'){
	
	my $old_code = $obj->{'_access_code'};
	
	$obj->access_edit();
	
	$obj->{'_access_geted'} = 0;
	$obj->access('r');
	
	if($obj->{'_access_code'} ne $old_code){ sess()->{'admin_refresh_left'} = 1; }
	
	if(param('submit') eq 'OK'){ $do_list = 1; return; }
    }
    if($chact eq 'addlist'){ $obj->access_add_list(); return; }
    if($chact eq 'add'){ $obj->access_add(param('memb')); }
    if($chact eq 'del'){ $obj->access_del(param('memb')); }
    
    $obj->access_view();
}

sub jchown
{
    my $url = param('url');
    my $uid = param('uid');
    my $obj = url($url);
    my $tu;
    
    if(!group()->{'root'}){ $obj->err_add('� ��� ��� ���� ������ ��������� ���������.'); return; }
    
    sess()->{'admin_refresh_left'} = 0;
    
    if($uid){
	
	$uid =~ s/\D//g;
	
	$tu = User->new();
	$tu->load($uid);
	
	if($tu->{'ID'} < 1){ $obj->err_add('��������� ������������ �� ����������.'); return; }
	
	$obj->ochown($uid);
	$obj->save();
	
	return;
    }
    
    $do_list = 0;
    
    my $nowu = User->new( $obj->{'OID'} );
    
    print '��������� ��������� ��� ��������: <b>',$obj->name(),'</b><br>';
    print '������� �������� ��������: <b>',$nowu->name(),'</b><br>';
    
    print '<br><br>�������� ������ ���������:<br><br>';
    
    my $count = 0;
    for $tu (User->sel_where(' 1 ')){
	
	if($tu->{'ID'} == $nowu->{'ID'}){ next; }
	print '<img src="img/dot.gif" align="absmiddle"> <a href="?act=chown&url=',$url,'&uid=',$tu->{'ID'},'">',$tu->name(),'</a><br>';
	$count++;
    }
    
    if(!$count){ print '<center><b>��� ������������� ��� �����������.</b></center>'; }
}

sub move2
{
    my $url = param('url');
    my $uto = param('to');
    my $enum = param('enum');
    my $ref = param('ref');
    
    my $from = url($url);
    my $elem = $from->elem($enum);
    
    if(!$from->access('w')){ $from->err_add('� ��� ��� ���������� �������� ���� �������.'); return; }
    if(!$elem->access('w')){ $from->err_add('� ��� ��� ���������� �������� ������������ �������.'); return; }
    if($elem->{'_is_shcut'}){ $from->err_add('������������ ������� �������� �������.'); return; }
    
    if($uto){
	
	my $to = url($uto);
	if(!$to->access('a')){ $from->err_add('� ��� ��� ���������� ��������� � ������� ����������.'); return; }
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
    
    sess()->{'admin_refresh_left'} = 0;
    $do_list = 0;
    
    my $eclass = ref($elem);
    
    print '�������� ������, � ������� ����������� �������: <b>',$elem->name(),'</b>.<br><br>';
    
    my $count = 0;
    
    my $c;
    for $c (@JDBI::classes){
	
	if( index( ${$c.'::add'}, ' '.$eclass.' ') < 0 and ${$c.'::add'} ne '*' ){ next; }
	if( $c eq 'UserGroupRoot' ){ next; }
	
	my @dirs = $c->sel_where(' 1 ');
	my $d;
	for $d (@dirs){
	    
	    if($from->myurl() eq $d->myurl()){ next; }
	    if($elem->myurl() eq $d->myurl()){ next; }
	    if(!$d->access('a')){ next; }
	    
	    print '<img src="',$d->admin_icon(),'" align="absmiddle"><a href="?act=move2&url=',$from->myurl(),'&to=',$d->myurl(),'&enum=',$enum,'&ref=1"><img align=absmiddle border=0 src="img/shcut.gif"></a> <a href="?act=move2&url=',$from->myurl(),'&to=',$d->myurl(),'&enum=',$enum,'&ref=0">',$d->name(),'</a><br>';
	    $count++;
	}
    }
    
    if(!$count){ print '<center><b>��� �������� ��� �����������.</b></center>'; }
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
    my $act = param('act');
    my $url = param('url');
    my $cn = param('cname');
    my $enum = param('enum');
    my $page = param('page');
    
    
    my $w = url($url);
    
    $do_list = 1;
    
    if($act){ sess()->{'admin_refresh_left'} = 1; }
    else{ return; }
    
    
    if($act eq 'edit'){
	
	my $tname = $w->name();
	$w->admin_edit();
	if($tname eq $w->name()){ sess()->{'admin_refresh_left'} = 0; }
    }
    
    if($act eq 'cre'){
	
	if(!JDBI::classOK($cn)){ return; }
	
	#print STDERR 'BEGIN';
	
	if(!$w->access('a')){ $w->err_add('� ��� ��� ���������� ��������� � ���� �������.'); return; }
	
	my $to = $cn->cre();
	$to->admin_edit();
	
	$w->elem_paste($to);
    }
    
    if($act eq 'adde'){
	
	if(!JDBI::classOK($cn)){ return; }
	
	if(!$w->access('a')){ $w->err_add('� ��� ��� ���������� ��������� � ���� �������.'); return; }
	
	sess()->{'admin_refresh_left'} = 0;
	$do_list = 0;
	
	my $to = $cn->new();
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
    my $url = param('url');
    
    unless($url){ print 'Error: url not specified!'; }
    
    my $to;
    $to = url($url);
    $to->admin_left();
}

sub tree
{
    my $url = param('url') | param('from');
    my $to;
    
    $to = url($url);
    
    $to->admin_tree();
}

sub install
{
    my ($i,$j,$is,$count,@created,$reinstall);
    
    if(!group()->{'root'}){ JIO::err403('Trying to (re)install, less group()->{"root"}'); return; }
    
    $reinstall = param('re');
    
    print '<center><h4>�������� ������.</h4></center><br>';
    
    if($reinstall){
	
	my $str;
	for $i ($JDBI::dbh->tables()){
	    
	    $str = $JDBI::dbh->prepare('DROP TABLE IF EXISTS '.$i);
	    $str->execute();
	}
    }
    
    
    JDBI->access_creTABLE();
    
    $count = 0;
    for $i (@JDBI::classes){
	
	$is = 0;
	
	for $j ($JDBI::dbh->tables()){
	    
	    if( lc('`dbo_'.$i.'`') eq lc($j) ){ $is = 1 }
	    if( lc('dbo_'.$i) eq lc($j) ){ $is = 1 }
	}
	
	if(!$is){
	    
	    $i->creTABLE();
	    push @created, $i;
	    $count++;
	}
	
    }
    
    print '<br>';
    print $count?( '������� ������: <b>'.$count.'</b>' ):( '������� ������� �� ���� �������.' );
    print '<br>';
    
    print '<hr><br><center><h4>��������� �������.</h4></center><br>';
    
    $count = 0;
    for $i (@created){
	
	if( defined &{$i.'::install'} ){
	    
	    print '��������� ������� "<b>',$i,'</b>"<br>';
	    &{$i.'::install'}($i);
	    print '<br>';
	    $count++;
	}
    }
    
    print '<br>';
    print $count?( '����������� ��������: <b>'.$count.'</b>' ):( '�������� ������� �� ���� �����������.' );
    print '<br>';
    
    print '<hr><br><center><h4>�������� ���������.</h4></center><br>';
    
    my $test = url('Dir1');
    
    if($test->{'ID'} != 1){
	
	my $root = Dir->cre();
	$root->{'name'} = '������� ��������';
	
	my $groot = UserRoot->cre();
	$groot->{'name'} = '������ �������������';
	
	
	#################################
	
	my $agroup = UserGroup->cre();
	$agroup->{'name'} = '��������������';
	$agroup->{'cms'} = 1;
	$agroup->{'html'} = 1;
	$agroup->{'root'} = 1;
	
	my $admin = User->cre();
	$admin->{'login'} = 'admin';
	$admin->{'pas'} = $admin->{'login'};
	$admin->{'name'} = '�������������';
	
	$agroup->elem_paste($admin);
	
	##################################
	
	
	my $ggroup = UserGroup->cre();
	$ggroup->{'name'} = '�����';
	$ggroup->{'cms'} = 0;
	$ggroup->{'html'} = 0;
	$ggroup->{'root'} = 0;
	
	my $guest = User->cre();
	$guest->{'login'} = '';
	$guest->{'pas'} = $guest->{'login'};
	$guest->{'name'} = '�����';
	
	$ggroup->elem_paste($guest);
	
	#################################
	
	$groot->elem_paste($agroup);
	$groot->elem_paste($ggroup);
	
	print '��� http �����: "<b>',$root->{'name'},'</b>"<br>';
	print '��� user �����: "<b>',$groot->{'name'},'</b>"<br>';
	print '����� � ������ ��������������: "<b>',$admin->{'login'},'</b>"<br>';
	print '��� ������ ��������������: "<b>',$agroup->{'name'},'</b>"<br>';
	print '����� � ������ �����: "<b>',$guest->{'login'},'</b>"<br>';
	print '��� ������ �����: "<b>',$ggroup->{'name'},'</b>"<br>';
	
	$admin->{'sid'} = sess()->{'JLogin_sid'};
	#$admin->save();
	#JLogin::login($admin->{'login'},$admin->{'pas'});
	
    }else{
	print '��������� ��� ���� �������.';
    }
    
    print '<br>';
}

sub modules
{
    my $m;
    my $sel_mod = param('mod');
    my($uname,$to);
    
    if($JConfig::users_do){
	$uname = group()->name().' / '.user()->name();
    }else{ $uname = '����������� �����'; }
    
    if(!$sel_mod){ $sel_mod = $def_mod }
    
    for $m (keys(%mods)){
	$to = url($mods{$m});
	if(!$to->access('x')){ next; }
	
	print '<nobr>';
	if($m eq $sel_mod){ print '<img src="',$to->admin_icon(),'" align=absmiddle> <b>',$m,'</b><br>' }
	else{ print '<img src="',$to->admin_icon(),'" align=absmiddle> <a href="?mod=',$m,'">',$m,'</a><br>' }
	print '</nobr>';
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

sub jscript
{
    if(sess()->{'admin_refresh_left'}){
	print 'parent.frames.admin_left.document.location.reload();';
    }
    
    delete(sess()->{'admin_refresh_left'});
    
    cmenus();
}

sub cmenus
{
    my $url;
    for $url (keys(%JDBI::dbo_cache)){
	$JDBI::dbo_cache{$url}->admin_cmenu();
	print "\n\n";
    }
}

sub list
{
    my $page = param('page');
    my $url = param('url');
    my $act = param('act');
    
    if(!$do_list){ return; }
    
    my $w = url($url);
    $w->save();
    $w->reload();
    if(!$w->access('r')){ $w->err_add('� ��� ��� ���������� ��� ��������� ����� ��������.'); }
    $w->admin_view($page);
}

sub cms
{
    if(!group()->{'cms'}){
	JIO::err403('group()->{"cms"} != 1');
    }
}

return 1;

