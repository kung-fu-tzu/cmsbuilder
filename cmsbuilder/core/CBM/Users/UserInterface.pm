# CMSBuilder © Леонов П. А., 2005-2006

package CBM::Users::UserInterface;
use strict;
use utf8;


#———————————————————————————————————————————————————————————————————————————————

sub access
{
	my $o = shift;
	my $type = shift;
	
	return $type eq 'r' || $o->CMSBuilder::Object::access($type,@_);
}

1;