# CMSBuilder © Леонов П. А., 2006

package modSite::Data;
use strict qw(subs vars);
use utf8;

our @ISA = 'modSite::Interface';

sub _aview {qw/name template hidden title description/}

sub _props
{
	'name'				=> { 'type' => 'string', 'length' => 50, 'name' => 'Название' },
	'template'			=> { 'type' => 'ObjectsList', 'class' => 'modTemplates::Template', 'isnull' => 1, 'nulltext' => 'Наследовать', 'name' => 'Шаблон страницы' },
	'hidden'			=> { 'type' => 'checkbox', 'name' => 'Скрыть' },
	'title'				=> { 'type' => 'string', 'name' => 'Заголовок' },
	'description'		=> { 'type' => 'string', 'name' => 'Описание для поисковых роботов' },
}

#———————————————————————————————————————————————————————————————————————————————



1;