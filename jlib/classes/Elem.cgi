package Elem;
use strict qw(subs vars);

use vars '%props';
use vars '$name';
use vars '@ISA';
use vars '$page';

$name = '�������';
@ISA = 'DBObject';
$page = '/page.ehtml';

%props = (
	
	'name'	  => { 'type' => 'string', 'length' => 100, 'name' => '��������' },
	'etext'	  => { 'type' => 'text', 'name' => '����������' }
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