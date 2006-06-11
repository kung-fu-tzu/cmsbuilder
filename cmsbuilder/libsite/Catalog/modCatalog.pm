# (с) Леонов П.А., 2005

package modCatalog;
use strict qw(subs vars);
our @ISA = ('plgnCatalog::Member','plgnSite::Member','CMSBuilder::DBI::TreeModule');

our $VERSION = 1.0.0.0;

sub _cname {'Каталог'}
sub _aview {qw/name/}
sub _have_icon {1}


#-------------------------------------------------------------------------------


sub install_code {}
sub mod_is_installed {1}


1;