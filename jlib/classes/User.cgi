package User;
$name = '������������';
@ISA = 'DBObject';
$page = '/page.ehtml';
use strict qw(subs vars);

my %props = (
	
	'name'	  => { 'type' => 'string', 'length' => 50, 'name' => '���' },
	'login'	  => { 'type' => 'string', 'length' => 50, 'name' => '�����' },
	'pas'	  => { 'type' => 'string', 'length' => 50, 'name' => '������' },
	'sid'	  => { 'type' => 'string', 'length' => 20, 'name' => '����' },
	'gid'	  => { 'type' => 'int', 'name' => '����� ������' },
	'icq'	  => { 'type' => 'int', 'length' => 15, 'name' => '����� ����' },
	'email'	  => { 'type' => 'string', 'length' => 50, 'name' => '����' },
	'city'	  => { 'type' => 'string', 'length' => 30, 'name' => '�����' },
);

sub props { return %props; }

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