package UserGroup;
$name = '������ �������������';
$page = '/page.ehtml';
$pages_direction = 0;
$add  = ' User ';
@ISA = 'DBArray';
use strict qw(subs vars);

my %props = (

	'name'	  => { 'type' => 'string', 'length' => 100, 'name' => '��� ������' },
	'adminka' => { 'type' => 'checkbox', 'name' => '������ � �������' }
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