package Papa;
use strict qw(subs vars);

our $name = 'Родитель';
our @ISA = 'JDBI::Object';
our $page = '/page';

our %props = (
	
	'name'	  => { 'type' => 'string', 'length' => 100, 'name' => 'Название' },
	'son'	  => { 'type' => 'object', 'class' => 'Elem', 'name' => 'Сын' },
	'etext'	  => { 'type' => 'miniword', 'name' => 'Содержимое' }
);

sub DESTROY
{
	my $o = shift;
	$o->SUPER::DESTROY(@_);
}

return 1;