# (�) ������ �.�., 2005

package Papa;
use strict qw(subs vars);
our @ISA = 'JDBI::Object';

sub _cname {'��������'}
sub _aview {qw/name etext son/}
sub _have_icon {0}

sub _props
{
	'name'		=> { 'type' => 'string', 'length' => 100, 'name' => '��������' },
	'son'		=> { 'type' => 'object', 'class' => 'Elem', 'name' => '���' },
	#'etext'	=> { 'type' => 'string', 'length' => 100, 'name' => '����������' },
	'etext'		=> { 'type' => 'miniword', 'name' => '����������' }
}

#-------------------------------------------------------------------------------


sub des_page { print $_[0]->{'etext'}; }

1;