package UserGroupDir;
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
$pages_direction = 0;
$add  = ' UserGroup ';
@ISA = 'DBArray';

%props = (

	'name'	  => { 'type' => 'string', 'length' => 100, 'name' => 'Имя' }
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