# (�) ������ �.�., 2005

package plgnUsers::UserInterface;
use strict qw(subs vars);


#-------------------------------------------------------------------------------

sub access
{
	my $o = shift;
	my $type = shift;
	
	return $type eq 'r' ? 1 : $o->plgnAccess::ObjectHook::access($type,@_);
}

1;