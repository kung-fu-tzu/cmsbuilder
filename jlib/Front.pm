# (с) Леонов П.А., 2005

package Front;
use strict qw(subs vars);
import CGI 'param';
import JDBI;
import JIO;
use CMS::fileman;

sub path
{
	url(param('url'))->admin_path();
}

sub user_xinfo
{
	my $name = shift;
	
	if($name eq 'main_menu')
	{
		unless($JDBI::group->{'root'}){ print '&nbsp;'; return; }
		if($JDBI::group->{'cpanel'}){ print '<a href="left.ehtml?url=ModControlPanel1" onclick="admin_right.location.href = \'right.ehtml?url=ModControlPanel1\'; admin_left.location.href = \'left.ehtml?url=ModControlPanel1\'; return false;"><img align="absmiddle" alt="Панель управления" src="img/cpanel.gif"></a>'; }
	}
	
	if($name eq 'name')
	{
		my $uname;
		
		if($JConfig::access_on_e)
		{
			$uname = $JDBI::group->name().' / '.$JDBI::user->name();
		}
		else
		{
			$uname = 'Монопольный режим';
		}
		
		print $uname;
	}
	
	if($name eq 'exit')
	{
		unless($JConfig::access_on_e){ return; }
		print '<a href="',$JConfig::http_eroot,'/login.ehtml?act=out"><img align="absmiddle" alt="Выход" src="img/logoff.gif"></a>';
	}
	
	if($name eq 'shtoolbox')
	{
		print '<textarea style="DISPLAY: none" id="shtoolbox">';
		Front::user_xinfo('main_menu');
		print '&nbsp;&nbsp;';
		Front::user_xinfo('exit');
		print '</textarea>';
		
		print '<textarea style="DISPLAY: none" id="shbottombox">';
		Front::user_xinfo('name');
		print '</textarea>';
	}
	
	if($name eq 'fileman_btn')
	{
		unless($JDBI::group->{'files'}){ return; }
		print '<span class="fileman_menu">';
		print '<span class="hidden" id="fileman_edit_bar">';
		print '<a href="edit" onclick="return false"><img onclick="admin_fileman.CMS_FMTogleE()" alt="Редактирование" src="icons/edit.gif"></a>&nbsp;';
		print '<a href="refresh" onclick="return false"><img onclick="admin_fileman.location.href = admin_fileman.location.href" alt="Обновить" src="icons/refresh.gif"></a>&nbsp;';
		print '</span>';
		print '<img width="16" height="16" src="img/null.gif">';
		print '<a id="tree_btn" class="hover" href="tree" onclick="return false"><img onclick="CMS_Set_Left(\'left\')" alt="Дерево" src="icons/folders.gif"></a>&nbsp;';
		print '<a id="mydocs_btn" href="mydocuments" onclick="return false"><img onclick="CMS_Set_Left(\'fileman\')" alt="Мои документы" src="icons/mydocs.gif"></a>&nbsp;';
		print '</span>';
	}
}

sub modules
{
	unless(ModRoot->table_have())
	{
		print '<br><center>Структура базы не установлена!</center>
		<script language="JavaScript">
			parent.admin_right.location.href = "right.ehtml?url=ModControlPanel1";
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
	
	if($mod)
	{
		print '
		<script language="JavaScript">
			parent.admin_left.location.href = "',$mod->admin_left_href(),'";
			parent.admin_right.location.href = "',$mod->admin_right_href(),'";
			parent.module_div_it.innerText = "',$mod->name(),'";
			SelectMod(id_',$mod->myurl(),');
			
			function CMS_TellLH() { return "',$mod->admin_left_href(),'"; }
			function CMS_TellModName() { return "',$mod->name(),'"; }
		</script>
		';
	}
	
	unless(@mods){ print '<br><center>Нет модулей для отображения.</center>'; }
}

sub right
{
	my $url = param('url');
	my $to = url($url);
	
	return $to->admin_view_right();
}

sub left
{
	my $url = param('url');
	my $to = url($url);
	
	return $to->admin_view_left();
}

sub jscript
{
	if(sess()->{'admin_refresh_left'} and $JConfig::have_left_tree and $JConfig::have_left_frame)
	{
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
	for my $to (values(%JDBI::dbo_cache))
	{
		$to->admin_cmenu();
		print "\n\n";
	}
}

sub access
{
	unless($JDBI::group->{'cms'})
	{
		JIO::err402('$JDBI::group->{"cms"} != 1');
	}
}


1;