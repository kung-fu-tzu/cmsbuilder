package UserRoot;
use strict qw(subs vars);

use vars '%props';
use vars '$name';
use vars '$page';
use vars '$pages_direction';
use vars '@aview';
use vars '$add';
use vars '@ISA';
use vars '$dont_list_me';

$name = 'Корень пользователей';
$page = '/page.ehtml';
$pages_direction = 1;
$add  = ' UserGroup ';
@ISA = 'JDBI::Array';

%props = (

	'name'	  => { 'type' => 'string', 'length' => 100, 'name' => 'Имя' }
);

sub DESTROY
{
	my $o = shift;
	$o->SUPER::DESTROY();
}

return 1;