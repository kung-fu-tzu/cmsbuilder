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

$name = 'Директория';
$page = '/page.ehtml';
$pages_direction = 0;
#@aview = qw/name onpage/;
$add  = ' Elem Dir Papa ';
@ISA = 'JDBI::Array';
$dont_list_me = 0;

%props = (
	
	'name'    => { 'type' => 'string', 'length' => 100, 'name' => 'Название' },
	'onpage'  => { 'type' => 'int', 'name' => 'Элементов на странице' }
);

sub DESTROY
{
	my $o = shift;
	$o->SUPER::DESTROY();
}

return 1;