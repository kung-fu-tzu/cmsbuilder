# CMSBuilder © Леонов П. А., 2005-2006

package modRecycleBin::UserBin;
use strict qw(subs vars);
use utf8;

use CMSBuilder::IO;
use modUsers::API;

our @ISA = qw(modAdmin::Tree CMSBuilder::DBI::Array);

sub _cname {'Корзина'}
sub _add_classes {'*'}
sub _one_instance {1}
sub _have_icon {'icons/RecycleBin.png'}


#-------------------------------------------------------------------------------

sub admin_add_list {}

sub name
{
	my $o = shift;
	
	return $o->_cname(@_) . ($o->papa && $o->papa->myurl ne $user->myurl ? '&nbsp;('.$o->papa->name.')' : '');
}


1;