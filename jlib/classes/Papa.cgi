package Papa;
use strict qw(subs vars);

use vars '%props';
use vars '$name';
use vars '@ISA';
use vars '$page';
use vars '@aview';

$name = 'Родитель';
@ISA = 'DBObject';
$page = '/page.ehtml';

%props = (
	
	'name'	  => { 'type' => 'string', 'length' => 100, 'name' => 'Название' },
	'son'	  => { 'type' => 'object', 'class' => 'Elem', 'name' => 'Сын' },
	'etext'	  => { 'type' => 'miniword', 'name' => 'Содержимое' }
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