# CMSBuilder © Леонов П. А., 2005-2006

package modUsers::UserInterface;
use strict qw(subs vars);
use utf8;


#———————————————————————————————————————————————————————————————————————————————

sub access
{
	my $o = shift;
	my $type = shift;
	
	return $type eq 'r' || $o->CMSBuilder::DBI::Object::access($type,@_);
}

1;