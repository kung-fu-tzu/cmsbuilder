package Text;
$name = '���������&nbsp;��������';
@ISA = 'DBObject';
use strict qw(subs vars);

sub props
{
	my %props = (

		'url'	=> { 'type' => 'string', 'length' => 100, 'name' => '����� � ��������� (���� ����)' },
		'name'	=> { 'type' => 'string', 'length' => 50, 'name' => '��������' },
		'context' => { 'type' => 'text', 'name' => '�����' },
		'str'	=> { 'type' => 'object', 'class' => 'Str', 'name' => '������ ������' }

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