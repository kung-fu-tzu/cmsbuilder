# (�) ������ �.�., 2005

package Elem;
use strict qw(subs vars);
our @ISA = 'JDBI::Object';

sub _cname {'�������'}
sub _aview {qw/name etext tf/}

sub _props
{
	'name'		=> { 'type' => 'string', 'length' => 100, 'name' => '��������' },
	'etext'		=> { 'type' => 'text', 'name' => '����������' },
	'tf'		=> { 'type' => 'file', 'msize' => 100, 'ext' => ' bmp jpg gif txt html ', 'name' => '����' }
}

#-------------------------------------------------------------------------------


1;