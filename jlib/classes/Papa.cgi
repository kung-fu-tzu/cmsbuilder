package Papa;
$name = '��������';
@ISA = 'DBObject';
$page = '/page.ehtml';
use strict qw(subs vars);

my %props = (
	
	'name'	  => { 'type' => 'string', 'length' => 100, 'name' => '��������' },
	'son'	  => { 'type' => 'object', 'class' => 'Elem', 'name' => '���' },
	'etext'	  => { 'type' => 'miniword', 'name' => '����������' }
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