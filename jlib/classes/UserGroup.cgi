package UserGroup;
$name = 'Группа пользователей';
$page = '/page.ehtml';
$pages_direction = 0;
$add  = ' User ';
@ISA = 'DBArray';
use strict qw(subs vars);

my %props = (

	'name'	  => { 'type' => 'string', 'length' => 100, 'name' => 'Имя группы' }
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