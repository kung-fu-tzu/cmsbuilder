package Papa;
use strict qw(subs vars);

our $name = '��������';
our @ISA = 'JDBI::Object';
our $page = '/page';
our @aview = qw/name etext son/;

our %props = (
	'name'		=> { 'type' => 'string', 'length' => 100, 'name' => '��������' },
	'son'		=> { 'type' => 'object', 'class' => 'Elem', 'name' => '���' },
	'etext'		=> { 'type' => 'string', 'length' => 100, 'name' => '����������' }
	#'etext'	=> { 'type' => 'miniword', 'name' => '����������' }
);

return 1;