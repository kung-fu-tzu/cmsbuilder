package User;
$name = 'Пользователь';
@ISA = 'DBObject';
use strict qw(subs vars);

sub props
{
	my %props = (

		'name'	  => { 'type' => 'string', 'length' => 50, 'name' => 'Ник' },
		'login'	  => { 'type' => 'string', 'length' => 50, 'name' => 'Логин' },
		'pas'	  => { 'type' => 'string', 'length' => 50, 'name' => 'Пароль' },
		'sid'	  => { 'type' => 'string', 'length' => 20, 'name' => 'Ключ' },
		'gid'	  => { 'type' => 'int', 'name' => 'Номер группы' }
	);

	return %props;
}

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