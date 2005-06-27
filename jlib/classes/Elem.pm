# (с) Леонов П.А., 2005

package Elem;
use strict qw(subs vars);
our @ISA = 'JDBI::Object';

sub _cname {'Элемент'}
sub _aview {qw/name etext tf/}

sub _props
{
	'name'		=> { 'type' => 'string', 'length' => 100, 'name' => 'Название' },
	'etext'		=> { 'type' => 'text', 'name' => 'Содержимое' },
	'tf'		=> { 'type' => 'file', 'msize' => 100, 'ext' => ' bmp jpg gif txt html ', 'name' => 'File' }
}

#-------------------------------------------------------------------------------


1;