package Elem;
$name = 'Элемент';
@ISA = 'DBObject';
$page = '/page.ehtml';
use strict qw(subs vars);


sub props
{
	my %props = (

		'name'	  => { 'type' => 'string', 'length' => 100, 'name' => 'Название' },
		'etext'	  => { 'type' => 'text', 'name' => 'Содержимое' }

	);

	return %props;
}

sub new
{
	my $o = {};
	bless($o);

	$o->_construct(@_);

	return $o;
}

sub DESTROY
{
	my $o = shift;
	$o->SUPER::DESTROY();
}

return 1;