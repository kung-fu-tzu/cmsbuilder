package Dir;
use strict qw(subs vars);

use vars '%props';
use vars '$name';
use vars '$page';
use vars '$pages_direction';
use vars '@aview';
use vars '$add';
use vars '@ISA';
use vars '$dont_list_me';

$name = '����������';
$page = '/page.ehtml';
$pages_direction = 0;
#@aview = qw/name onpage/;
$add  = ' Elem Dir Papa ';
@ISA = 'DBArray';
$dont_list_me = 0;

%props = (
	
	'name'	  => { 'type' => 'string', 'length' => 100, 'name' => '��������' },
	'onpage'  => { 'type' => 'int', 'name' => '��������� �� ��������' }
);

sub go
{
	my $o = shift;
	
	print '<nobr><b>go(',$o,')</b></nobr>';
	
}

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