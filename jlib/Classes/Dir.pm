package Dir;
use strict qw(subs vars);

our $name = 'Директория';
our $page = '/page';
our $pages_direction = 1;
#our @aview = qw/name onpage/;
our $add  = ' Elem Dir Papa ';
our @ISA = 'JDBI::Array';
our $dont_list_me = 0;
our $icon = 1;

our %props = (
	'name'	=> { 'type' => 'string', 'length' => 100, 'name' => 'Название' },
	'onpage'  => { 'type' => 'int', 'name' => 'Элементов на странице' }
);

return 1;