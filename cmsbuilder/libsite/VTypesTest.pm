# (�) ������ �.�., 2005

package VTypesTest;
use strict qw(subs vars);
our @ISA = 'CMSBuilder::DBI::TreeModule';

sub _cname {'���� ��� �-�����'}
sub _aview
{qw/
	string string1 string2 int checkbox
	|
	ClassList ClassList1 ClassList2
	date timestamp time
	|
	file object
	|
	password password1
	|
	select radio
	|
	miniword text
/}

sub _props
{
	'string'		=> { 'type' => 'string', 'name' => '������' },
	'string1'		=> { 'type' => 'string', 'big' => 1, 'name' => '������ (�������)' },
	'string2'		=> { 'type' => 'string', 'length' => 10, 'name' => '������ (10)' },
	'int'			=> { 'type' => 'int', 'name' => '�����' },
	'checkbox'		=> { 'type' => 'checkbox', 'name' => '�������' },
	
	'ClassList'		=> { 'type' => 'ClassList', 'class' => 'User', 'name' => '�������� �������� (User)' },
	'ClassList1'	=> { 'type' => 'ClassList', 'class' => 'User', 'isnull' => 1, 'name' => '�������� �������� (User) ������' },
	'ClassList2'	=> { 'type' => 'ClassList', 'class' => 'User', 'once' => 1, 'name' => '�������� �������� (User) ����������' },
	
	'date'			=> { 'type' => 'date', 'name' => '����' },
	'timestamp'		=> { 'type' => 'timestamp', 'name' => '������' },
	'time'			=> { 'type' => 'time', 'name' => '�����' },
	
	'file'			=> { 'type' => 'file', 'msize' => 100, 'ext' => [qw/bmp jpg gif png/], 'name' => '����' },
	'object'		=> { 'type' => 'object', 'class' => 'Page', 'name' => '������' },
	'password'		=> { 'type' => 'password', 'name' => '������' },
	'password1'		=> { 'type' => 'password', 'check' => 1, 'name' => '������ (� ������ ��������)' },
	
	'select'		=> { 'type' => 'select', 'variants' => [{'1'=>'����'},{'2'=>'���'},{'3'=>'���'}], 'name' => '���������� ������' },
	'radio'			=> { 'type' => 'radio', 'variants' => [{'1'=>'����'},{'2'=>'���'},{'3'=>'���'}], 'name' => '�������������' },
	
	'text'			=> { 'type' => 'text', 'name' => '���� ������' },
	
	'miniword'		=> { 'type' => 'miniword', 'toolbar' => 'Basic', 'name' => '��������' },
}

#-------------------------------------------------------------------------------


sub install_code {}
sub mod_is_installed {1}

1;