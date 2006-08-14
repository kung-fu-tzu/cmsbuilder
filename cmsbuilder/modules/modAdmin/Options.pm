# CMSBuilder © Леонов П. А., 2005-2006

package modAdmin::Options;
use strict qw(subs vars);
use utf8;

our @ISA = qw(CMSBuilder::DBI::Object CMSBuilder::DBI::Object::ONoBase);

our $pkg = __PACKAGE__;

sub _cname {'Настройки'}

sub _rpcs {keys %{{_simplem_menu()}}}
sub _aview {'root'}
sub _have_icon {'icons/system.png'}

sub name {$_[0]->_cname}

sub _props
{
	root		=> { type => 'ObjectsList', class => modAdmin::modAdmin->root_class, name => 'Корень модулей' },
}

sub _simplem_menu
{
		cpanel_mod_admin	=> { -obj => $pkg->new(1), -papa => 'cpanel_modules' },
		cpanel_mod_root	=> { -obj => modAdmin::modAdmin->root, -papa => 'cpanel_modules' },
}

#———————————————————————————————————————————————————————————————————————————————

use CMSBuilder;
use CMSBuilder::IO;
use CMSBuilder::IO::GUI;

sub reload
{
	my $o = shift;
	
	$o->{'root'} = cmsb_url($modules_ini->{'modRoot'});
}

sub save
{
	my $o = shift;
	return unless $o->access('w');
	
	$modules_ini->{'modRoot'} = $o->{'root'}->myurl;
}

sub admin_view
{
	my $o = shift;
	my $r = shift;
	
	admin_fieldset_begin('modAdmin_Options_view','Настройки');
	
	if($r->{'add_modroot'})
	{
		my $to = modAdmin::modAdmin->root_class->cre();
		$to->papa_set($o->papa);
		
		if($to)
		{
			print 'Корень добавлен: ', $to->admin_name;
		}
		else
		{
			print 'Не удалось добавить корень: ', $!;
		}
	}
	
	print '<p><a href="',$o->admin_right_href,'&add_modroot=yes">Добавить корень</a></p>';
	
	
	admin_fieldset_end();
	
	$o->SUPER::admin_view($r,@_);	
}

sub papa {modControlPanel::ControlPanel->new(1)}

1;