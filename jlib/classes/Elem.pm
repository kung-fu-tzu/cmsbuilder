package Elem;
use strict qw(subs vars);

our $name = '�������';
our @ISA = 'JDBI::Object';
our $page = '/page';

our %props = (
	
	'name'	  => { 'type' => 'string', 'length' => 100, 'name' => '��������' },
	'etext'	  => { 'type' => 'text', 'name' => '����������' },
	'tf'	  => { 'type' => 'file', 'msize' => 100, 'ext' => ' bmp jpg gif txt html ', 'name' => 'File' }
);

sub DESTROY
{
	my $o = shift;
	$o->SUPER::DESTROY(@_);
}

return 1;