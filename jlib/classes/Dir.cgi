package Dir;
$name = '����������';
$page = '/page.ehtml';
$pages_direction = 0;
#@aview = qw/name onpage/;
$add  = ' Elem Dir Papa ';
@ISA = 'DBArray';
$dont_list_me = 0;
use strict qw(subs vars);

my %props = (

	'name'	  => { 'type' => 'string', 'length' => 100, 'name' => '��������' },
	'onpage'  => { 'type' => 'int', 'name' => '��������� �� ��������' }
);

sub props { return %props; }

sub new
{
	my $o = {};
	bless($o);

	return $o->_construct(@_);
}

sub DESTROY
{
	my $o = shift;
	$o->SUPER::DESTROY();
}

return 1;