package Elem;
use strict qw(subs vars);

our $name = 'Элемент';
our @ISA = 'JDBI::Object';
our $page = '/page';
our $icon = 1;

our %props = (
	'name'		=> { 'type' => 'string', 'length' => 100, 'name' => 'Название' },
	'etext'		=> { 'type' => 'text', 'name' => 'Содержимое' },
	'tf'		=> { 'type' => 'file', 'msize' => 100, 'ext' => ' bmp jpg gif txt html ', 'name' => 'File' }
);

return 1;