package Papa;
use strict qw(subs vars);

our $name = 'Родитель';
our @ISA = 'JDBI::Object';
our $page = '/page';
our @aview = qw/name etext son/;

our %props = (
    'name'	  => { 'type' => 'string', 'length' => 100, 'name' => 'Название' },
    'son'	  => { 'type' => 'object', 'class' => 'Elem', 'name' => 'Сын' },
    'etext'	  => { 'type' => 'string', 'length' => 100, 'name' => 'Содержимое' }
    #'etext'	  => { 'type' => 'miniword', 'name' => 'Содержимое' }
);

return 1;