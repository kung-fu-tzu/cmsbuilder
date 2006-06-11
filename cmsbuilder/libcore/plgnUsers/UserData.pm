# (с) Леонов П.А., 2005

package plgnUsers::UserData;
use strict qw(subs vars);

sub _aview {qw/login pas/}

sub _props
{
	'login'		=> { 'type' => 'string', 'name' => 'Логин' },
	'pas'		=> { 'type' => 'password', 'check' => 1, 'name' => 'Пароль' },
}

#-------------------------------------------------------------------------------


1;