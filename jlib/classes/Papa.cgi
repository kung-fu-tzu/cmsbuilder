package Papa;
$name = 'Родитель';
@ISA = 'DBObject';
$page = '/page.ehtml';
use strict qw(subs vars);

my %props = (
	
	'name'	  => { 'type' => 'string', 'length' => 100, 'name' => 'Название' },
	'son'	  => { 'type' => 'object', 'class' => 'Elem', 'name' => 'Сын' },
	'etext'	  => { 'type' => 'miniword', 'name' => 'Содержимое' }
);

sub props { return %props; }

sub new
{
	my $o = {};
	bless($o);

	return $o->_construct(@_);
}

sub DESTROY
{
	my $o = shift;
	$o->SUPER::DESTROY();
}

return 1;