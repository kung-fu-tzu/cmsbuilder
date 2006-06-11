# (с) Леонов П.А., 2005

package Client;
use strict qw(subs vars);
our @ISA = ('plgnUsers::UserMember','CMSBuilder::DBI::Object');

sub _cname {'Клиент'}
sub _aview {qw/name email ccn/}

sub _props
{
	'name'		=> { 'type' => 'string', 'name' => 'Имя' },
	'email'		=> { 'type' => 'string', 'name' => 'E-Mail' },
	'ccn2'		=> { 'type' => 'string', 'name' => 'Кредитка' },
}

#-------------------------------------------------------------------------------


1;