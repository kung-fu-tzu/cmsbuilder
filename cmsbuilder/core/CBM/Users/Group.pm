# CMSBuilder © Леонов П. А., 2005-2006

package CBM::Users::Group;
use strict;
use utf8;

our @ISA = qw(CMSBuilder::Object);

sub class_name {'Группа пользователей'}
sub _add_classes {qw(CBM::Users::UserMember)}
sub _aview {qw(name html files cms root cpanel)}
sub admin_icon {'icons/Users_Group.png'}

sub _props
{
	name		=> { type => 'string', length => 100, name => 'Имя группы' },
	html		=> { type => 'checkbox', name => '<b>HTML</b>' },
	files		=> { type => 'checkbox', name => 'Загрузка файлов' },
	root		=> { type => 'checkbox', name => 'Суперпользователи' },
	cms			=> { type => 'checkbox', name => 'Доступ в <b>Систему Администрирования</b>' },
	cpanel		=> { type => 'checkbox', name => 'Доступ в <b>Панель управления</b>' }
}

#———————————————————————————————————————————————————————————————————————————————


1;