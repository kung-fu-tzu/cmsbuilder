package User;
use strict qw(subs vars);

our $name = 'Пользователь';
our @ISA = 'JDBI::Object';
our @aview = qw/name login pas icq email city/;
our $page = '/page';

our %props = (
	
	'name'	  => { 'type' => 'string', 'length' => 50, 'name' => 'Имя' },
	'login'	  => { 'type' => 'string', 'length' => 50, 'name' => 'Логин' },
	'pas'	  => { 'type' => 'password', 'length' => 50, 'name' => 'Пароль' },
	'sid'	  => { 'type' => 'string', 'length' => 20, 'name' => 'Ключ' },
	'icq'	  => { 'type' => 'int', 'length' => 15, 'name' => '#ICQ' },
	'email'	  => { 'type' => 'string', 'length' => 50, 'name' => 'E-Mail' },
	'city'	  => { 'type' => 'string', 'length' => 30, 'name' => 'Город' },
);

sub install
{
	my $class = shift;
	my $str;
	
	$str = $JDBI::dbh->prepare('ALTER TABLE `dbo_'.$class.'` ADD INDEX ( `sid` )');
	$str->execute();
	
	$str = $JDBI::dbh->prepare('ALTER TABLE `dbo_'.$class.'` ADD INDEX ( `login` )');
	$str->execute();
}

sub save
{
	my $o = shift;
	my($pas,$ret);
	
	$pas = $o->{'pas'};
	if($o->{'pas'}){ $o->{'pas'} = JDBI->MD5($o->{'pas'}); }
	$ret = $o->SUPER::save(@_);
	$o->{'pas'} = $pas;
	
	return $ret;
}

sub DESTROY
{
	my $o = shift;
	$o->SUPER::DESTROY(@_);
}

return 1;