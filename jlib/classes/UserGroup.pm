package UserGroup;
use strict qw(subs vars);

our $name = '������ �������������';
our $page = '/page';
our $pages_direction = 1;
our $add  = ' User ';
our @aview = qw/name html files cms root/;
our @ISA = 'JDBI::Array';
our $icon = 1;

our %props = (
	
	'name'  => { 'type' => 'string', 'length' => 100, 'name' => '��� ������' },
	'html'  => { 'type' => 'checkbox', 'name' => '��������� <b>HTML</b>' },
	'files' => { 'type' => 'checkbox', 'name' => '��������� �������� ������' },
	'root'  => { 'type' => 'checkbox', 'name' => '������ ������' },
	'cms'   => { 'type' => 'checkbox', 'name' => '������ � <b>��</b>' }
);

sub DESTROY
{
	my $o = shift;
	$o->SUPER::DESTROY(@_);
}

return 1;