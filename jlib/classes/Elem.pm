package Elem;
use strict qw(subs vars);

our $name = '�������';
our @ISA = 'JDBI::Object';
our $page = '/page';
our $icon = 1;

our %props = (
    'name'	  => { 'type' => 'string', 'length' => 100, 'name' => '��������' },
    'etext'	  => { 'type' => 'text', 'name' => '����������' },
    'tf'	  => { 'type' => 'file', 'msize' => 100, 'ext' => ' bmp jpg gif txt html ', 'name' => 'File' }
);

return 1;