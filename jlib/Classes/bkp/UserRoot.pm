package UserRoot;
use strict qw(subs vars);

our $name = 'Корень пользователей';
our $page = '/page';
our $pages_direction = 1;
our $add  = ' UserGroup ';
our @ISA = 'JDBI::Array';
our $icon = 1;

our %props = (
	'name'	  => { 'type' => 'string', 'length' => 100, 'name' => 'Имя' }
);

sub DESTROY
{
	my $o = shift;
	$o->SUPER::DESTROY(@_);
}

return 1;