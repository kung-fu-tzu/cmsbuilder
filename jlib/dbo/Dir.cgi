package Dir;

$name = '����������';
@ISA = 'DBArray';

sub props
{
	my %props = (

		url	=> { type => string, length => 100, name => '����� � ���������' },
		on_page	=> { type => 'int', name => '���-�� ��������� �� ��������' },
		ndate	=> { type => 'date', name => '���� �������' }
	);

	return %props;
}

sub new
{
	my $o = {};
	bless($o);

	$o->{PROPS} = %props;
	$o->_construct(@_);

	return $o;
}

sub DESTROY
{
	my $o = shift;
	$o->SUPER::DESTROY();
}

return 1;