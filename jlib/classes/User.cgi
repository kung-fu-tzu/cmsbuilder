package User;
$name = '������������';
@ISA = 'DBObject';
@aview = qw/name login pas icq email city/;
$page = '/page.ehtml';
use strict qw(subs vars);

my %props = (
	
	'name'	  => { 'type' => 'string', 'length' => 50, 'name' => '���' },
	'login'	  => { 'type' => 'string', 'length' => 50, 'name' => '�����' },
	'pas'	  => { 'type' => 'password', 'length' => 50, 'name' => '������' },
	'sid'	  => { 'type' => 'string', 'length' => 20, 'name' => '����' },
	'icq'	  => { 'type' => 'int', 'length' => 15, 'name' => '����� ����' },
	'email'	  => { 'type' => 'string', 'length' => 50, 'name' => '����' },
	'city'	  => { 'type' => 'string', 'length' => 30, 'name' => '�����' },
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