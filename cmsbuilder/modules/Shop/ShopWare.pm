# CMSBuilder © Леонов П. А., 2006

package modShop::Ware;
use strict qw(subs vars);
use utf8;

sub _aview {qw/name price qnt tobasket/}

sub _props
{
	'qnt'		=> { 'type' => 'int', 'name' => 'Количество' }, # quantity
	'tobasket'	=> { 'type' => 'moveToBasket', 'name' => 'В корзину' },
}

#———————————————————————————————————————————————————————————————————————————————

1;