# (�) ������ �.�., 2006

package plgnSite::Data;
use strict qw(subs vars);
our @ISA = 'plgnSite::Interface';

sub _aview {qw/name template hidden title description/}

sub _props
{
	'name'				=> { 'type' => 'string', 'length' => 50, 'name' => '��������' },
	'template'			=> { 'type' => 'ClassList', 'class' => 'Template', 'isnull' => 1, 'nulltext' => '�����������', 'name' => '������ ��������' },
	'hidden'			=> { 'type' => 'checkbox', 'name' => '������' },
	'title'				=> { 'type' => 'string', 'name' => '���������' },
	'description'		=> { 'type' => 'string', 'name' => '�������� ��� ��������� �������' },
}

#-------------------------------------------------------------------------------



1;