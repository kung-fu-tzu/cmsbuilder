package Dir;
$name = '����������';
@ISA = 'DBArray';
use strict qw(subs vars);

sub props
{
	my %props;

	%props = (

		'url'	  => { 'type' => 'string', 'length' => 100, 'name' => '����� � ���������' },
		'on_page' => { 'type' => 'int', 'name' => '���-�� ��������� �� ��������' },
		'ndate'	  => { 'type' => 'date', 'name' => '���� �������' }
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