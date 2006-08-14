# CMSBuilder © Леонов П. А., 2005-2006

package modRecycleBin::UserHook;
use strict qw(subs vars);
use utf8;

sub _aview {'recyclebin'}

sub _props
{
	recyclebin		=> { type => 'object', class => 'modRecycleBin::UserBin', name => 'Корзина' },
}


1;