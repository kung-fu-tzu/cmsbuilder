# (�) ������ �.�., 2005

package UserGroup;
use strict qw(subs vars);
our @ISA = 'CMSBuilder::DBI::Array';

sub _cname {'������ �������������'}
sub _add_classes {qw/plgnUsers::UserMember/}
sub _aview {qw/name html files cms root cpanel/}
sub _have_icon {1}

sub _props
{
	'name'		=> { 'type' => 'string', 'length' => 100, 'name' => '��� ������' },
	'html'		=> { 'type' => 'checkbox', 'name' => '<b>HTML</b>' },
	'files'		=> { 'type' => 'checkbox', 'name' => '�������� ������' },
	'root'		=> { 'type' => 'checkbox', 'name' => '�����������������' },
	'cms'		=> { 'type' => 'checkbox', 'name' => '������ � <b>��</b>' },
	'cpanel'	=> { 'type' => 'checkbox', 'name' => '������ � <b>������ ����������</b>' }
}

#-------------------------------------------------------------------------------c


1;