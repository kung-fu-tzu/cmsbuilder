package HttpRoot;
use strict qw(subs vars);

our $name = 'Главная страница';
our $page = '/page';
our $pages_direction = 1;
our $add  = ' Elem Dir Papa ';
our @ISA = 'JDBI::Array';
our $dont_list_me = 0;
our $icon = 1;

our %props = (
	
	'name'    => { 'type' => 'string', 'length' => 100, 'name' => 'Название' }
);

sub DESTROY
{
	my $o = shift;
	$o->SUPER::DESTROY(@_);
}

return 1;