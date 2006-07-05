# (с) Леонов П.А., 2006

package plgnSite::Data;
use strict qw(subs vars);
use utf8;

our @ISA = 'plgnSite::Interface';

sub _aview {qw/name template hidden title description/}

sub _props
{
	'name'				=> { 'type' => 'string', 'length' => 50, 'name' => 'Название' },
	'template'			=> { 'type' => 'ObjectsList', 'class' => 'Template', 'isnull' => 1, 'nulltext' => 'Наследовать', 'name' => 'Шаблон страницы' },
	'hidden'			=> { 'type' => 'checkbox', 'name' => 'Скрыть' },
	'title'				=> { 'type' => 'string', 'name' => 'Заголовок' },
	'description'		=> { 'type' => 'string', 'name' => 'Описание для поисковых роботов' },
}

#———————————————————————————————————————————————————————————————————————————————



1;