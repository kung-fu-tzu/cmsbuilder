# (�) ������ �.�., 2005

package Dir;
use strict qw(subs vars);
our @ISA = 'JDBI::Array';

sub _cname {'����������'}
sub _aview {keys %{{_props()}}}
#sub _aview {qw/- name onpage/}
sub _add_classes {qw/Elem Dir Papa ShortCut/}

sub _props
{
	'name'	=> { 'type' => 'string', 'length' => 100, 'name' => '��������' },
	'descr'	=> { 'type' => 'string', 'length' => 50, 'name' => '��������' }
}

#-------------------------------------------------------------------------------


1;