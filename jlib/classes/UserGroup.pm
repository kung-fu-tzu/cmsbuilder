package UserGroup;
use strict qw(subs vars);

our $name = '������ �������������';
our $page = '/page';
our $pages_direction = 1;
our $add  = ' User ';
our @aview = qw/name html files cms root cpanel/;
our @ISA = 'JDBI::Array';
our $icon = 1;

our %props = (
	'name'	=> { 'type' => 'string', 'length' => 100, 'name' => '��� ������' },
	'html'	=> { 'type' => 'checkbox', 'name' => '<b>HTML</b>' },
	'files'   => { 'type' => 'checkbox', 'name' => '�������� ������' },
	'root'	=> { 'type' => 'checkbox', 'name' => '�����������������' },
	'cms'	 => { 'type' => 'checkbox', 'name' => '������ � <b>��</b>' },
	'cpanel'  => { 'type' => 'checkbox', 'name' => '������ � <b>������ ����������</b>' }
);

return 1;