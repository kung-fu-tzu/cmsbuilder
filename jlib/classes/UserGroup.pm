package UserGroup;
use strict qw(subs vars);

use vars '%props';
use vars '$name';
use vars '$page';
use vars '$pages_direction';
use vars '@aview';
use vars '$add';
use vars '@ISA';
use vars '$dont_list_me';

$name = 'Группа пользователей';
$page = '/page.ehtml';
$pages_direction = 0;
$add  = ' User ';
@aview = qw/name html cms root/;
@ISA = 'JDBI::Array';

%props = (

	'name'  => { 'type' => 'string', 'length' => 100, 'name' => 'Имя группы' },
	'html'  => { 'type' => 'checkbox', 'name' => 'Разрешить <b>HTML</b>' },
	'root'  => { 'type' => 'checkbox', 'name' => 'Полный доступ' },
	'cms'   => { 'type' => 'checkbox', 'name' => 'Доступ к <b>СА</b>' }
);

sub DESTROY
{
	my $o = shift;
	$o->SUPER::DESTROY();
}

return 1;