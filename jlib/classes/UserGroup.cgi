package UserGroup;
use strict qw(subs vars);

use vars '%props';
use vars '$name';
use vars '$page';
use vars '$pages_direction';
use vars '@aview';
use vars '$add';
use vars '@ISA';
use vars '$dont_list_me';

$name = '������ �������������';
$page = '/page.ehtml';
$pages_direction = 0;
$add  = ' User ';
@ISA = 'DBArray';

%props = (

	'name'	  => { 'type' => 'string', 'length' => 100, 'name' => '��� ������' },
	'adminka' => { 'type' => 'checkbox', 'name' => '������ � �������' }
);

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