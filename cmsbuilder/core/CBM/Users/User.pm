# CMSBuilder © Леонов П. А., 2005-2006

package CBM::Users::User;
use strict;
use utf8;

our @ISA = qw(CBM::Users::UserMember CMSBuilder::Object);

sub class_name {'Пользователь'}
sub _aview {qw/name email/}
sub admin_icon {'icons/Users_User.png'}

sub _props
{
	name		=> { type => 'string', name => 'Имя' },
	email		=> { type => 'string', name => 'E-Mail' },
}

#———————————————————————————————————————————————————————————————————————————————

sub create
{
	my $c = shift;
	
	my $o = $c->SUPER::create(@_);
	
	$o->owner_set($o, r => 1);
	
	return $o;
}


1;