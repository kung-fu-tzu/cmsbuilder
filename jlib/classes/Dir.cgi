package Dir;
$name = '����������';
$page = '/page.ehtml';
$pages_direction = 0;
#@aview = qw/name onpage/;
$add  = 'Elem Dir';
@ISA = 'DBArray';
use strict qw(subs vars);

sub props
{
	my %props = (

		'name'	  => { 'type' => 'string', 'length' => 100, 'name' => '��������' },
		'onpage'  => { 'type' => 'int', 'name' => '��������� �� ��������' }
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