package UserGroup;
use strict qw(subs vars);

our $name = 'Группа пользователей';
our $page = '/page';
our $pages_direction = 1;
our $add  = ' User ';
our @aview = qw/name html files cms root/;
our @ISA = 'JDBI::Array';

our %props = (
	
	'name'  => { 'type' => 'string', 'length' => 100, 'name' => 'Имя группы' },
	'html'  => { 'type' => 'checkbox', 'name' => 'Разрешить <b>HTML</b>' },
	'files' => { 'type' => 'checkbox', 'name' => 'Разрешить загрузку файлов' },
	'root'  => { 'type' => 'checkbox', 'name' => 'Полный доступ' },
	'cms'   => { 'type' => 'checkbox', 'name' => 'Доступ к <b>СА</b>' }
);

sub DESTROY
{
	my $o = shift;
	$o->SUPER::DESTROY(@_);
}

return 1;