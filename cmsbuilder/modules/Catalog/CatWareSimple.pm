# CMSBuilder © Леонов П. А., 2005-2006

package CatWareSimple;
use strict qw(subs vars);
use utf8;

our @ISA = qw(modCatalog::Ware CMSBuilder::DBI::Object);

sub _cname {'Товар'}
#sub _aview {qw(name price photo desc)}

#———————————————————————————————————————————————————————————————————————————————


1;