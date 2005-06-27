# (с) Леонов П.А., 2005

package UserGroup;
use strict qw(subs vars);
our @ISA = 'JDBI::Array';

sub _cname {'Группа пользователей'}
sub _add_classes {qw/User/}
sub _aview {qw/name html files cms root cpanel/}

sub _props
{
	'name'		=> { 'type' => 'string', 'length' => 100, 'name' => 'Имя группы' },
	'html'		=> { 'type' => 'checkbox', 'name' => '<b>HTML</b>' },
	'files'		=> { 'type' => 'checkbox', 'name' => 'Загрузка файлов' },
	'root'		=> { 'type' => 'checkbox', 'name' => 'Суперпользователи' },
	'cms'		=> { 'type' => 'checkbox', 'name' => 'Доступ в <b>СА</b>' },
	'cpanel'	=> { 'type' => 'checkbox', 'name' => 'Доступ в <b>Панель управления</b>' }
}

#-------------------------------------------------------------------------------c


1;