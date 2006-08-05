# (с) Леонов П.А., 2005

package modShop::Dir;
use strict qw(subs vars);
use utf8;

sub _aview {qw/asware/}

sub _props
{
	'asware'	=> { 'type' => 'bool', 'name' => 'Выводить как товар' }, # quantity
}

#———————————————————————————————————————————————————————————————————————————————

1;