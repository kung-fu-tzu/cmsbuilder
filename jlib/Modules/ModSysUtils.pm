package ModSysUtils;
use strict qw(subs vars);
our @ISA = 'StdModule';

our $name = 'Системные Утилиты';
our @classes = qw/ShortCut/;

our $page = '/page';
our $add  = ' ';
our @aview = qw/name/;
our $one_instance = 1;
our $simple = 1;
our $icon = 1;

our %props = (
	'name'	=> { 'type' => 'string', 'length' => 50, 'name' => 'Название' }
);

return 1;