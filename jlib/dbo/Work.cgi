package Work;
$name = '������';
@ISA = 'DBObject';
use strict qw(subs vars);

sub props
{
	my %props = (

		'url'	  => { 'type' => 'string', 'length' => 100, 'name' => '����� � ���������' },
		'name'	  => { 'type' => 'string', 'length' => 50, 'name' => '�������� ������' },
		'img'	  => { 'type' => 'file', 'mime' => 'image/jpeg', 'msize' => 1024*500, 'ext' => '.jpg', 'name' => '��������� ��������' },
		'big'	  => { 'type' => 'file', 'mime' => 'image/jpeg', 'msize' => 1024*1024, 'ext' => '.jpg', 'name' => '������� ��������' },
		'context' => { 'type' => 'text', 'name' => '������� ���������' },
		'tobj'    => { 'type' => 'object', 'class' => 'Text', 'name' => '��������� ������' }
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