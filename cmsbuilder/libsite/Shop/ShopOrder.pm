# (с) Леонов П. А., 2005

package ShopOrder;
use strict qw(subs vars);
use utf8;

our @ISA = ('modSite::Object','CMSBuilder::DBI::Array');

sub _cname {'Заказ'}
sub _aview {qw/name/}

sub _props
{
	
}

#———————————————————————————————————————————————————————————————————————————————



1;