# (�) ������ �.�., 2005

package CMSBuilder::DBI::Object;
use strict qw(subs vars);

our @ISA =
(
	'CMSBuilder::DBI::Object::OAdmin',
	'CMSBuilder::DBI::Object::OCore',
	'CMSBuilder::DBI::Object::OBase',
	
	'CMSBuilder::DBI::RPC',
	'CMSBuilder::DBI::CMS',
	'CMSBuilder::DBI::EventsInterface'
);

sub _cname {'������'}

#-------------------------------------------------------------------------------


1;