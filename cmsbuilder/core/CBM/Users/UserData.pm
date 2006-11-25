# CMSBuilder © Леонов П. А., 2005-2006

package CBM::Users::UserData;
use strict;
use utf8;

sub _aview {qw/login pas remind/}

sub _props
{
	login		=> { type => 'string', name => 'Логин' },
	pas		=> { type => 'password', check => 1, name => 'Пароль' },
	remind	=> { type => 'string', name => 'Код напоминания' },
}

#———————————————————————————————————————————————————————————————————————————————


1;