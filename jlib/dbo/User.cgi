package User;
$name = '������������';
@ISA = 'DBObject';
use strict qw(subs vars);

sub props
{
	my %props = (

		'name'	  => { 'type' => 'string', 'length' => 50, 'name' => '���' },
		'login'	  => { 'type' => 'string', 'length' => 50, 'name' => '�����' },
		'pas'	  => { 'type' => 'string', 'length' => 50, 'name' => '������' },
		'sid'	  => { 'type' => 'string', 'length' => 20, 'name' => '����' },
		'gid'	  => { 'type' => 'int', 'name' => '����� ������' }
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