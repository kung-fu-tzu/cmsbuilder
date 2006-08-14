# CMSBuilder © Леонов П. А., 2005-2006

package modTemplates::Dir;
use strict qw(subs vars);
use utf8;

our @ISA = qw(CMSBuilder::DBI::Array);

sub _cname {'Раздел шаблонов'}
sub _aview {keys %{{_props()}}}
sub _add_classes {qw(modTemplates::Template)}

sub _props
{
	name		=> { type => 'string', length => 25, name => 'Название' },
}

#———————————————————————————————————————————————————————————————————————————————



1;