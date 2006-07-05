# (с) Леонов П.А., 2005

package modCatalog;
use strict qw(subs vars);
use utf8;

our @ISA = ('plgnCatalog::Member','plgnSite::Member','CMSBuilder::DBI::TreeModule');

our $VERSION = 1.0.0.0;

sub _cname {'Каталог'}
sub _aview {qw/name shownophoto nophotoimg/}
sub _have_icon {1}

sub _props
{
	'shownophoto'	=> { 'type' => 'bool', 'name' => 'Выводить картинку по умолчанию' },
	'nophotoimg'	=> { 'type' => 'img', 'name' => 'Картинка по умолчанию' },
}

#———————————————————————————————————————————————————————————————————————————————

sub install_code {}
sub mod_is_installed {1}


1;