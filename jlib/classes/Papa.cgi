package Papa;
$name = '��������';
@ISA = 'DBObject';
$page = '/page.ehtml';
use strict qw(subs vars);


sub props
{
	my %props = (

		'name'	  => { 'type' => 'string', 'length' => 100, 'name' => '��������' },
		'son'	  => { 'type' => 'object', 'class' => 'Elem', 'name' => '���' },
		'etext'	  => { 'type' => 'text', 'name' => '����������' }

	);

	return %props;
}

sub new
{
	my $o = {};
	bless($o);

	$o->_construct(@_);

	return $o;
}

sub DESTROY
{
	my $o = shift;
	$o->SUPER::DESTROY();
}

return 1;