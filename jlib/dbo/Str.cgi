package Str;
@ISA = 'DBObject';
$name = 'Строка';
use strict qw(subs vars);

sub props
{
	my %props = (

		'url'	=> { 'type' => 'string', 'length' => 100, 'name' => 'Адрес в интернете' }
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

sub name {
	my $o = shift;
	return $o->{url}?$o->{url}:$o->SUPER::name();
}

sub DESTROY
{
	my $o = shift;
	$o->SUPER::DESTROY();
}

return 1;