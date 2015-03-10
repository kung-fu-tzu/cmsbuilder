﻿# CMSBuilder © Леонов П. А., 2005-2006

package CMSBuilder::DBI::Object;
use strict qw(subs vars);
use utf8;

our @ISA =
(
	'CMSBuilder::DBI::Object::OAdmin',
	'CMSBuilder::DBI::Object::OCore',
	'CMSBuilder::DBI::Object::OBase',
	
	'CMSBuilder::DBI::RPC',
	#'CMSBuilder::DBI::EventsInterface',

	'modAdmin::CMSObject',
);

sub _cname {'Объект'}

#———————————————————————————————————————————————————————————————————————————————


1;