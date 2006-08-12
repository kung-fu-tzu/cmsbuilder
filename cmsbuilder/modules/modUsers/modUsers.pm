# CMSBuilder © Леонов П. А., 2005-2006

package modUsers::modUsers;
use strict qw(subs vars);
use utf8;

our @ISA = qw(modAdmin::Tree CMSBuilder::DBI::Array CMSBuilder::Module);

sub _cname {'Пользователи'}
sub _add_classes {qw(modUsers::Group)}
sub _one_instance {1}
sub _have_icon {1}

sub _props
{
	'name'	=> { 'type' => 'string', 'length' => 50, 'name' => 'Название' },
}

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder;
use CMSBuilder::IO;
use CMSBuilder::Utils;
use modUsers::API;

sub admin_additional
{
	my $o = shift;
	
	my $chown = $o->access('o')?'&nbsp;(<a href="?url='.$o->myurl().'&act=cms_chown"><u>изменить&nbsp;владельца</u></a>)':'';
	
	print '<tr><td valign="top">Владелец:</td><td valign="top">',$o->owner->name(),$chown,'</td></tr>';
}

sub mod_load
{
	my $c = shift;
	
	cmsb_event_reg('admin_view_additional',\&admin_additional);
}

sub mod_init
{
	my $c = shift;
	
	modUsers::API->init();
	
	if($CMSBuilder::Config::access_auto_off && $CMSBuilder::Config::access_on_e)
	{
		$CMSBuilder::Config::access_on_e = 0;
		
		if(modUsers::modUsers->table_have())
		{
			my $tu = cmsb_url($CMSBuilder::Config::user_admin);
			
			if($tu)
			{
				$CMSBuilder::Config::access_on_e = 1;
			}
		}
	}
	
	if($CMSBuilder::Config::access_on_e)
	{
		su_start($CMSBuilder::Config::user_guest);
		modUsers::API->verif();
	}
	else
	{
		$user  = modUsers::User->new();
		$user->{'ID'}		= $CMSBuilder::Config::user_admin;
		$user->{'name'}		= 'Монопольный режим';
		
		$group = modUsers::Group->new();
		$group->{'ID'}		= 1;
		$group->{'name'}	= 'Администраторы';
		
		$group->{'html'}	= 1;
		$group->{'files'}	= 1;
		$group->{'cms'}		= 1;
		$group->{'root'}	= 1;
		$group->{'cpanel'}	= 1;
	}
}

sub install_code
{
	my $mod = shift;
	my($mr,$tm,$tg,$tu);
	$mr = modAdmin::modAdmin->root;
	
	$tm = $mod->cre();
	$tm->{'name'} = 'Пользователи';
	$tm->save();
	$mr->elem_paste($tm);
	
	$tg = modUsers::Group->cre();
	$tg->{'name'}   = 'Администраторы';
	$tg->{'html'}   = 1;
	$tg->{'files'}  = 1;
	$tg->{'cms'}	= 1;
	$tg->{'root'}   = 1;
	$tg->{'cpanel'} = 1;
	$tg->save();
	
	$tm->elem_paste($tg);
	
	$tu = modUsers::User->cre();
	$tu->{'name'}   = 'Администратор';
	$tu->{'login'}  = 'admin';
	$tu->save();
	$tg->elem_paste($tu);
	
	$tu = modUsers::User->cre();
	$tu->{'name'}   = 'Барменталь';
	$tu->{'login'}  = 'barmental';
	$tu->save();
	$tg->elem_paste($tu);
	
	$tg = modUsers::Group->cre();
	$tg->{'name'}   = 'Гости';
	$tg->save();
	
	$tm->elem_paste($tg);
	
	$tu = modUsers::User->cre();
	$tu->{'name'}   = 'Гость';
	$tu->save();
	
	$tg->elem_paste($tu);
}

1;