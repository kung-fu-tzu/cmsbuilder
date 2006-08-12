# CMSBuilder © Леонов П. А., 2005-2006

package modAdmin::modAdmin;
use strict qw(subs vars);
use utf8;

our @ISA = qw(CMSBuilder::Module);

use Carp;

use CMSBuilder;
use CMSBuilder::IO;

sub _cname {'Админка'}

our
(
	$root_class,
	%cmenus
);


#———————————————————————————————————————————————————————————————————————————————


sub root { return cmsb_url($modules_ini->{'modRoot'}) || cmsb_url($_[0]->root_class . '1') || carp 'No modules root found ('.$_[0]->root_class.')'; }
sub root_class { $root_class }

sub mod_init
{
	$root_class = 'modAdmin::Root';
}

sub mod_load
{
	my $c = shift;
	
	push @modControlPanel::ControlPanel::ISA, 'modAdmin::Options';
}

sub install_code {}
sub mod_is_installed {1}

1;