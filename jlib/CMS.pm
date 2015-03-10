package CMS;
use strict qw(subs vars);
use CGI ('param');
use JDBI;
use JIO;

our $def_mod = 'ModUsers';
our $do_list;

sub jchmod { require $JConfig::path_lib.'/CMS/jchmod.pl'; jchmod(@_); }
sub jchown { require $JConfig::path_lib.'/CMS/jchown.pl'; jchown(@_); }
sub move2  { require $JConfig::path_lib.'/CMS/move2.pl';  move2(@_); }

sub mkshcut
{
	my $w = url(param('url'));
	my $enum = param('enum');
	
	my $to = $w->elem($enum);
	
	my $to_sh = $to->shcut_cre();
	$w->elem_paste($to_sh);
	
}

sub arr_sort
{
	my $by = param('by');
	
	my $w = url(param('url'));
	
	if($by eq 'reverse'){ $w->reverse(); }
	if($by eq 'class'){ $w->sortT('CLASS'); }
	if($by eq 'id'){ $w->sortT('ID'); }
	if($by eq 'num'){ $w->sortT('num'); }
	if($by eq 'ats'){ $w->update_ats_cts(); $w->sortT('ATS'); }
	if($by eq 'cts'){ $w->update_ats_cts(); $w->sortT('CTS'); }
}

sub action
{
	my $act = param('act');
	my $url = param('url');
	my $cn = param('cname');
	my $enum = param('enum');
	my $page = param('page');
	
	$do_list = 1;
	
	if($act){ sess()->{'admin_refresh_left'} = 1; }
	else{ return; }
	
	unless($url){ print '������: url �� ����������!'; return; }
	my $w = url($url);
	
	
	if($act eq 'edit'){
		
		my $tname = $w->name();
		$w->admin_edit();
		$w->save();
		$w->reload(); # ��������� ���������, �������� ATS, OID, �������� � ���� ����� reload()
		if($tname eq $w->name()){ sess()->{'admin_refresh_left'} = 0; }
	}
	
	if($act eq 'cre'){
		
		if(!JDBI::classOK($cn)){ return; }
		
		if(!$w->access('a')){ $w->err_add('� ��� ��� ���������� ��������� � ���� �������.'); return; }
		
		my $to = $cn->cre();
		$to->admin_edit();
		$w->save();
		
		$w->elem_paste($to);
	}
	
	if($act eq 'adde'){
		
		unless(JDBI::classOK($cn)){ return; }
		
		unless($w->access('a')){ $w->err_add('� ��� ��� ���������� ��������� � ���� �������.'); return; }
		
		sess()->{'admin_refresh_left'} = 0;
		$do_list = 0;
		
		my $to = $cn->new();
		$to->admin_cre($w);
	}
	
	if($act eq 'move'){
		
		$w->elem_moveto($enum,param('nnum'));
	}
	
	if($act eq 'dele'){ $w->elem_del($enum); }
	
	if($act eq 'eup'){ $w->elem_moveup($enum); }
	
	if($act eq 'edown'){ $w->elem_movedown($enum); }
	
	if($act eq 'move2' or $act eq 'mkshcut'){ move2($act); }
	
	if($act eq 'chown'){ jchown(); }
	
	if($act eq 'chmod'){ jchmod(); }
	
	if($act eq 'arr_sort'){ arr_sort(); }
}

sub left_tree
{
	unless($JConfig::have_left_tree){
		print '<br><br><br><center>������ ��������� ���������.</center>';
		return;
	}
	
	my $url = param('url');
	unless($url){ print '������: url �� ����������!'; return; }
	
	url($url)->admin_left();
}

sub tree
{
	url(param('url'))->admin_tree();
}

sub main_menu
{
	unless($JDBI::group->{'root'}){ print '&nbsp;'; return; }
	
	if($JDBI::group->{'cpanel'}){ print '<a target="admin_right" href="cpanel.ehtml"><img align="absmiddle" alt="������ ����������" src="img/cpanel.gif"></a>'; }
	
}

sub cpanel
{
	if(!$JDBI::group->{'root'})  { JIO::err403('Trying to cpanel, less $JDBI::group->{"root"}'); return; }
	if(!$JDBI::group->{'cpanel'}){ JIO::err403('Trying to cpanel, less $JDBI::group->{"cpanel"}'); return; }
	
	my $act = param('act');
	my $mod;
	my $refresh = 0;
	
	if($act eq 'table_cre'){
		
		$refresh = 1;
		
		JDBI::access_creTABLE();
		ModRoot->table_cre();
		my $mr = ModRoot->cre();
		$mr->{'name'} = '������ �������';
		$mr->save();
		
		print '������� ���� �������, ������� ���������� � ������ ������� ������� �����������.<br><br>';
		
		for $mod (@JDBI::modules){ $mod->table_cre() }
	}
	
	if($act eq 'table_fix'){
		my $ch;
		for $mod (@JDBI::modules){ $ch |= $mod->table_fix(); }
		
		print '<br>';
		if($ch){ print '��������� ���������.'; }
		else{ print '���������� �� ���������.'; }
	}
	
	if($act eq 'object_stat'){
		
		for $mod (@JDBI::modules,'',@JDBI::classes){
			
			unless($mod){ print '<br>'; next; }
			
			print 
		}
	}
	
	if($act eq 'install_mods'){
		
		$refresh = 1;
		
		for $mod (@JDBI::modules){ $refresh = $mod->install() && $refresh; }
			
		if($refresh){ print '<br>������ ������� �����������.'; }
		else{ print '<br>��������� �� ���������.'; }
	}
		
	unless(ModRoot->table_have()){
		print '��������� ���� �� �����������! <a href="?act=table_cre"><b>����������...</b></a>';
		return;
	}
	
	if($act){ print '<br><br><a href="cpanel.ehtml">�����...</a>'; }
	
	unless($act){
		
		print url('ModRoot1')->admin_name(),'<br>';
		print '<img src="icons/install.gif" align="absmiddle">&nbsp;&nbsp;<a target="admin_right" href="cpanel.ehtml?act=table_fix">�������� ���������...</a><br>';
		print '<img src="icons/install.gif" align="absmiddle">&nbsp;&nbsp;<a target="admin_right" href="cpanel.ehtml?act=install_mods">��������� ������...</a><br><br>';
		
		print '<img src="icons/install.gif" align="absmiddle">&nbsp;&nbsp;<a target="admin_right" href="cpanel.ehtml?act=object_stat">���������� ��������</a><br>';
	}
	
	if($refresh){ print '<script language="JavaScript">parent.frames.admin_modules.document.location.href = parent.frames.admin_modules.document.location.href;</script>'; }
}

sub user_name
{
	my $uname;
	
	if($JConfig::users_do_e){
		$uname = $JDBI::group->name().' / '.$JDBI::user->name();
	}else{ $uname = '����������� �����'; }
	
	print $uname;
}

sub user_exit
{
	unless($JConfig::users_do_e){ return; }
	print '<a href="',$JConfig::http_eroot,'/login.ehtml?act=out"><img align="absmiddle" alt="�����" src="img/logoff.gif"></a>';
}

sub user_shtoolbox
{
	print '<textarea style="DISPLAY: none" id="shtoolbox">';
	CMS::main_menu();
	print '&nbsp;&nbsp;';
	CMS::user_exit();
	print '</textarea>';
	
	print '<textarea style="DISPLAY: none" id="shbottombox">';
	CMS::user_name();
	print '</textarea>';
}

sub modules
{
	unless(ModRoot->table_have()){
		print '<br><center>��������� ���� �� �����������!</center>
		<script language="JavaScript">
			parent.admin_right.location.href = "cpanel.ehtml";
		</script>
		';
		return;
	}
	
	my $mr = url('ModRoot1');
	my @mods = $mr->get_all();
	my $mod;
	
	for $mod (@mods){ print $mod->admin_name('?mod='.$mod->myurl(),'admin_modules'),'<br>'; }
	
	my $um = param('mod');
	if($um){ $mod = url($um); }else{ $mod = $mods[0]; }
	
	if($mod){
		print '
		<script language="JavaScript">
			parent.admin_left.location.href = "',$mod->admin_left_href(),'";
			parent.admin_right.location.href = "',$mod->admin_right_href(),'";
			parent.module_div_it.innerText = "',$mod->name(),'";
			SelectMod(id_',$mod->myurl(),');
		</script>
		';
		
	}
	
	unless(@mods){ print '<br><center>��� ������� ��� �����������.</center>'; }
}

sub modr
{
	my $url = param('url');
	my $to = url($url);
	
	$to->admin_modr();
}

sub modl
{
	my $url = param('url');
	my $to = url($url);
	
	$to->admin_modl();
}

sub jscript
{
	if(sess()->{'admin_refresh_left'} and $JConfig::have_left_tree and $JConfig::have_left_frame){
		print 'if(CMS_HaveParent()) parent.frames.admin_left.document.location.href = parent.frames.admin_left.document.location.href;';
	}
	
	delete(sess()->{'admin_refresh_left'});
	
	print ' if(CMS_HaveParent()) parent.document.all.tree_div_it.innerHTML = tree_div.innerText;
		else tree_div_it.innerHTML = tree_div.innerText;
	';
	
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
	
	unless($do_list){ return; }
	
	my $w = url($url);
	
	#$w->elem_paste(url('User1')->shcut());
	
	unless($w->access('r')){ $w->err_add('� ��� ��� ���������� ��� ��������� ����� ��������.'); }
	$w->admin_view($page);
}

sub cms
{
	unless($JDBI::group->{'cms'}){
		JIO::err402('$JDBI::group->{"cms"} != 1');
	}
}

return 1;

