# CMSBuilder © Леонов П. А., 2005-2006

package modAdmin::Front;
use strict qw(subs vars);
use utf8;

import CGI 'param';
use CMSBuilder;
use CMSBuilder::IO::GUI;
use modUsers::API;
use CMSBuilder::IO;

sub user_xinfo
{
	my $name = shift;
	
	
	if($name eq 'left_td_width')
	{
		my %cook = CGI::cookie('left_td');
		print $cook{'width'} || $CMSBuilder::Config::admin_left_width;
	}
	
	elsif($name eq 'main_menu')
	{
		my $cnt;
		
		print '<span class="toolpanel">';
		
		if($group->{'cpanel'})
		{
			print '<a title="Обновить структуру" href="',modControlPanel::ControlPanel->new(1)->admin_right_href(),'&act=cpanel_table_fix" target="admin_right"><img src="icons/table.png" /></a><img src="img/nx.png" />';
		}
		
		if($group->{'files'})
		{
			print '<a title="Мои документы"   onclick="return selectLeftPanel(\'admin_docs_icon\')" id="admin_docs_icon" href="fileman.ehtml"><img src="icons/mydocs.png" /></a>';
			$cnt++;
		}
		
		if($group->{'cpanel'})
		{
			print modControlPanel::ControlPanel->new(1)->admin_toolbar_icon();
			$cnt++;
		}
		
		print '<a'.($cnt?'':' style="display: none"').' title="Выбранный модуль" onclick="return selectLeftPanel(\'admin_modules_icon\')" id="admin_modules_icon" href="about:blank"><img src="icons/folders.png" /></a>';
		
		print '</span>';
	}
	
	elsif($name eq 'name')
	{
		my $uname;
		
		if($CMSBuilder::Config::access_on_e)
		{
			$uname = $group->name().' / '.$user->name();
		}
		else
		{
			$uname = 'Монопольный режим';
		}
		
		print $uname;
	}
	
	elsif($name eq 'exit')
	{
		unless($CMSBuilder::Config::access_on_e){ return; }
		if(is_guest($user))
		{
			print '<a href="login.ehtml">Вход</a>';
		}
		else
		{
			print '<a href="login.ehtml?act=out">Выход</a>';
		}
	}
}

sub modules
{
	unless(modAdmin::modAdmin->root_class->table_have())
	{
		print '<br><center>Структура базы не установлена!</center>
		<script language="JavaScript">
			parent.admin_right.location.href = "right.ehtml?url=modControlPanel::ControlPanel1";
			parent.admin_left.location.href = "left.ehtml?url=modControlPanel::ControlPanel1";
		</script>
		';
		
		return;
	}
	
	my $mr = modAdmin::modAdmin->root;
	return unless $mr;
	my @mods = $mr->get_all();
	
	for my $mod (@mods)
	{
		my %opts = $mod->admin_name_ex_opts();
		$opts{'-props'}{'onclick'} = 'SelectMod(id_'.$mod->jsid.',\''.$mod->admin_left_href().'\',\''.$mod->admin_right_href().'\'); return false;';
		print '<div>',admin_name_ex(%opts),'</div>';
	}
	
	if(@mods)
	{
		my $sm = $mods[0];
		my $so = $sm;
		
		if(my $to = cmsb_url(param('url')))
		{
			$sm = $to->root;
			$so = $to;
			print $to->admin_abs_href();
		}
		
		print
		'
			<script language="JavaScript">
				SelectMod(id_',$sm->jsid,',"',$sm->admin_left_href(),'","',$so->admin_right_href(),'");
			</script>
		';
	}
	else
	{
		print '<br><center>Нет модулей для отображения.</center>';
	}
}

sub right
{
	my $url = param('url');
	my $to = cmsb_url($url) || return;
	
	return $to->admin_view_right();
}

sub left
{
	my $url = param('url');
	my $to = cmsb_url($url) || return;
	
	return $to->admin_view_left();
}

sub left_head
{
	my $url = param('url');
	my $to = cmsb_url($url) || do { print '&nbsp;'; return };
	
	print $to->name();
}

sub jscript
{
	if($sess->{'admin_refresh_left'} and $CMSBuilder::Config::have_left_frame and $CMSBuilder::Config::have_left_tree)
	{
		print 'if(CMS_HaveParent()) parent.frames.admin_left.document.location.href = parent.frames.admin_left.document.location.href;';
	}
	
	delete $sess->{'admin_refresh_left'};
	
	my $to = cmsb_url(param('url'));
	
	print
	'
	function SafeRefresh()
	{
		',$to?('document.location.href = "',$to->admin_right_href(),'";'):'','
	}
	';
	
	cmenus();
	dnd();
}

sub path_html
{
	if(my $to = cmsb_url(param('url'))){ print $to->admin_path_html({CGI->Vars()}); }
}

sub path_js
{
	print '
	function CMS_admin_path()
	{
		if(CMS_HaveParent() && parent.admin_left.CMS_SelectLO)
		{
	';
	
	if(my $to = cmsb_url(param('url'))){ $to->admin_path_js({CGI->Vars()}); }
	
	print '
		}
	}
	CMS_admin_path();
	';
}

sub dnd
{
	print "var g_add_classes = new Object;\n\n";
	
	for my $tc (cmsb_classes())
	{
		print 'g_add_classes["'.$tc.'"] = [';
		
		if($tc->can('elem_can_add'))
		{
			print '"',join('","',grep {$tc->elem_can_add($_)} cmsb_classes()),'"';
		}
		
		print "]\n";
	}
}

sub rpccmenu
{
	my $to = cmsb_url(param('url')) || return;
	
	$to->admin_cmenu();
	
	print
	'
	
	if(all_menus_code["'.$to->jsid.'"] != undefined)
		ShowCMenu("'.$to->jsid.'",'.param('mx').','.param('my').');
	';
}

sub cmenus
{
	return;
	for my $to (values(%CMSBuilder::dbo_cache))
	{
		$to->admin_cmenu();
		print "\n\n";
	}
}

sub access
{
	unless($group->{'cms'}){ CMSBuilder::IO::err403(); }
}


1;