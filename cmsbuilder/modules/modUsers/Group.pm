# CMSBuilder © Леонов П. А., 2005-2006

package modUsers::Group;
use strict qw(subs vars);
use utf8;

our @ISA = 'CMSBuilder::DBI::Array';

sub _cname {'Группа пользователей'}
sub _add_classes {qw/modUsers::UserMember/}
sub _aview {qw/name html files cms root cpanel/}
sub _have_icon {1}

sub _props
{
	name		=> { type => 'string', length => 100, name => 'Имя группы' },
	html		=> { type => 'checkbox', name => '<b>HTML</b>' },
	files		=> { type => 'checkbox', name => 'Загрузка файлов' },
	root		=> { type => 'checkbox', name => 'Суперпользователи' },
	cms		=> { type => 'checkbox', name => 'Доступ в <b>Систему Администрирования</b>' },
	cpanel	=> { type => 'checkbox', name => 'Доступ в <b>Панель управления</b>' }
}

#———————————————————————————————————————————————————————————————————————————————


1;