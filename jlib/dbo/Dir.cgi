package Dir;
$name = 'Директория';
@ISA = 'DBArray';
use strict qw(subs vars);

sub props
{
	my %props;

	%props = (

		'url'	  => { 'type' => 'string', 'length' => 100, 'name' => 'Адрес в интернете' },
		'on_page' => { 'type' => 'int', 'name' => 'Кол-во элементов на странице' },
		'ndate'	  => { 'type' => 'date', 'name' => 'Дата события' }
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