# (с) Леонов П.А., 2005

package modShop::User;
use strict qw(subs vars);
use utf8;

sub _aview {qw/basket/}

sub _props
{
	'basket'	=> { 'type' => 'object', 'class' => 'ShopBasket', 'name' => 'Корзина' },
}

#———————————————————————————————————————————————————————————————————————————————

1;