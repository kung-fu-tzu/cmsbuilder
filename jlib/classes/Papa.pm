# (с) Леонов П.А., 2005

package Papa;
use strict qw(subs vars);
our @ISA = 'JDBI::Object';

sub _cname {'Родитель'}
sub _aview {qw/name etext son/}
sub _have_icon {0}

sub _props
{
	'name'		=> { 'type' => 'string', 'length' => 100, 'name' => 'Название' },
	'son'		=> { 'type' => 'object', 'class' => 'Elem', 'name' => 'Сын' },
	#'etext'	=> { 'type' => 'string', 'length' => 100, 'name' => 'Содержимое' },
	'etext'		=> { 'type' => 'miniword', 'name' => 'Содержимое' }
}

#-------------------------------------------------------------------------------


sub des_page { print $_[0]->{'etext'}; }

1;