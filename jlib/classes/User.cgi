package User;
$name = 'Пользователь';
@ISA = 'DBObject';
@aview = qw/name login pas icq email city/;
$page = '/page.ehtml';
use strict qw(subs vars);

my %props = (
	
	'name'	  => { 'type' => 'string', 'length' => 50, 'name' => 'Ник' },
	'login'	  => { 'type' => 'string', 'length' => 50, 'name' => 'Логин' },
	'pas'	  => { 'type' => 'password', 'length' => 50, 'name' => 'Пароль' },
	'sid'	  => { 'type' => 'string', 'length' => 20, 'name' => 'Ключ' },
	'icq'	  => { 'type' => 'int', 'length' => 15, 'name' => 'Номер Аска' },
	'email'	  => { 'type' => 'string', 'length' => 50, 'name' => 'Мыло' },
	'city'	  => { 'type' => 'string', 'length' => 30, 'name' => 'Город' },
);

sub props { return %props; }

sub new
{
	my $o = {};
	bless($o);

	$o->_construct(@_);

	return $o;
}

sub DESTROY
{
	my $o = shift;
	$o->SUPER::DESTROY();
}

return 1;