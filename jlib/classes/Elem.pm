package Elem;
use strict qw(subs vars);

use vars '%props';
use vars '$name';
use vars '@ISA';
use vars '$page';

$name = 'Элемент';
@ISA = 'JDBI::Object';
$page = '/page.ehtml';

%props = (
	
	'name'	  => { 'type' => 'string', 'length' => 100, 'name' => 'Название' },
	'etext'	  => { 'type' => 'text', 'name' => 'Содержимое' },
	'tf'	  => { 'type' => 'file', 'msize' => 100, 'ext' => ' bmp jpg ', 'name' => 'File' }
);

sub DESTROY
{
	my $o = shift;
	$o->SUPER::DESTROY();
}

return 1;