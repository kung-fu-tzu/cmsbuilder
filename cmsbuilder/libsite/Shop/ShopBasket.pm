# (с) Леонов П. А., 2005

package ShopBasket;
use strict qw(subs vars);
use utf8;

our @ISA = ('ShopOrder','CMSBuilder::DBI::Array');

sub _cname {'Корзина'}
sub _aview {qw/name/}

sub _props
{
	
}

#———————————————————————————————————————————————————————————————————————————————



1;