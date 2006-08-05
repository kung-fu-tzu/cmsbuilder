# (с) Леонов П.А., 2005

package modCatalog::Data;
use strict qw(subs vars);
use utf8;

sub _aview {qw/photo desc/}

sub _props
{
	'photo'			=> { 'type' => 'img', 'msize' => 100, 'name' => 'Картинка' },
	'smallphoto'	=> { 'type' => 'sizedimg', 'for' => 'photo', 'size' => '100x*', 'quality' => 7, 'format' => 'jpeg'},
	'desc'			=> { 'type' => 'miniword', 'name' => 'Описание в каталоге' },
}

#———————————————————————————————————————————————————————————————————————————————

1;