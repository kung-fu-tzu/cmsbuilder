# (�) ������ �.�., 2005

package TemplateDir;
use strict qw(subs vars);
our @ISA = 'CMSBuilder::DBI::Array';

sub _cname {'������ ��������'}
sub _aview {keys %{{_props()}}}
sub _add_classes {qw/Template/}

sub _props
{
	'name'		=> { 'type' => 'string', 'length' => 25, 'name' => '��������' },
}

#-------------------------------------------------------------------------------



1;