package UserGroup;
use strict qw(subs vars);

our $name = 'Группа пользователей';
our $page = '/page';
our $pages_direction = 1;
our $add  = ' User ';
our @aview = qw/name html files cms root cpanel/;
our @ISA = 'JDBI::Array';
our $icon = 1;

our %props = (
	'name'	=> { 'type' => 'string', 'length' => 100, 'name' => 'Имя группы' },
	'html'	=> { 'type' => 'checkbox', 'name' => '<b>HTML</b>' },
	'files'   => { 'type' => 'checkbox', 'name' => 'Загрузка файлов' },
	'root'	=> { 'type' => 'checkbox', 'name' => 'Суперпользователи' },
	'cms'	 => { 'type' => 'checkbox', 'name' => 'Доступ к <b>СА</b>' },
	'cpanel'  => { 'type' => 'checkbox', 'name' => 'Доступ в <b>Панель управления</b>' }
);

return 1;