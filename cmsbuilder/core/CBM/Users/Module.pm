# CMSBuilder © Леонов П. А., 2005-2006

package CBM::Users::Module;
use strict;
use utf8;

our @ISA = qw(CMSBuilder::Module);

sub class_name {'Пользователи'}
sub admin_icon {'icons/Users_Module.png'}

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder;
use CMSBuilder::IO;
use CMSBuilder::Utils;
use CBM::Users;

sub admin_additional
{
	my $o = shift;
	
	my $chown = $o->access('o') ? '&nbsp;(<a href="?url='.$o->url.'&act=cms_chown"><u>изменить&nbsp;владельца</u></a>)' : '';
	
	print '<tr><td valign="top">Владелец:</td><td valign="top">', $o->owner ? $o->owner->name : 'не определен', $chown,'</td></tr>';
}

sub mod_load
{
	my $c = shift;
	
	cmsb_event_reg('admin_view_additional',\&admin_additional);
}

sub mod_init
{
	my $c = shift;
	
	CBM::Users->init();
	
	if($CMSBuilder::Config::access_auto_off && $CMSBuilder::Config::access_on_e)
	{
		$CMSBuilder::Config::access_on_e = 0;
		
		my $tu = eval { cmsb_url($CMSBuilder::Config::user_admin) };
		
		if($tu)
		{
			$CMSBuilder::Config::access_on_e = 1;
		}
	}
	
	if($CMSBuilder::Config::access_on_e)
	{
		su_start($CMSBuilder::Config::user_guest);
		CBM::Users->verif();
	}
	else
	{
		$user = bless {}, 'CBM::Users::User';
		$user->{'ID'}		= $CMSBuilder::Config::user_admin;
		$user->{'name'}		= 'Монопольный режим';
		
		$group = bless {}, 'CBM::Users::Group';
		$group->{'ID'}		= 1;
		$group->{'name'}	= 'Администраторы';
		
		$group->{'html'}	= 1;
		$group->{'files'}	= 1;
		$group->{'cms'}		= 1;
		$group->{'root'}	= 1;
		$group->{'cpanel'}	= 1;
	}
}

sub mod_install
{
	my $mod = shift;
	my($mr,$tm,$tg,$tu);
	$mr = modAdmin::modAdmin->root;
	
	$tm = $mod->create();
	$tm->{'name'} = 'Пользователи';
	$tm->save();
	$mr->child_paste($tm);
	
	$tg = CBM::Users::Group->create();
	$tg->{'name'}   = 'Администраторы';
	$tg->{'html'}   = 1;
	$tg->{'files'}  = 1;
	$tg->{'cms'}	= 1;
	$tg->{'root'}   = 1;
	$tg->{'cpanel'} = 1;
	$tg->save();
	
	$tm->child_paste($tg);
	
	$tu = CBM::Users::User->create();
	$tu->{'name'}   = 'Администратор';
	$tu->{'login'}  = 'admin';
	$tu->save();
	$tg->child_paste($tu);
	
	$tu = CBM::Users::User->create();
	$tu->{'name'}   = 'Барменталь';
	$tu->{'login'}  = 'barmental';
	$tu->save();
	$tg->child_paste($tu);
	
	$tg = CBM::Users::Group->create();
	$tg->{'name'}   = 'Гости';
	$tg->save();
	
	$tm->child_paste($tg);
	
	$tu = CBM::Users::User->create();
	$tu->{'name'}   = 'Гость';
	$tu->save();
	
	$tg->child_paste($tu);
}

1;