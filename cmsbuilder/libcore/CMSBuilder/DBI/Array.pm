# (�) ������ �.�., 2005

package CMSBuilder::DBI::Array;
use strict qw(subs vars);

our @ISA =
(
	'CMSBuilder::DBI::Array::AAdmin',
	'CMSBuilder::DBI::Array::ACore',
	'CMSBuilder::DBI::Array::ABase',
	
	'CMSBuilder::DBI::Object'
);

sub _cname {'������'}
sub _props {'onpage' => { 'type' => 'int', 'name' => '��������� �� ��������' }}

#-------------------------------------------------------------------------------


1;