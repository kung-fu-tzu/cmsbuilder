package Text;
$name = 'Текстовый&nbsp;документ';
@ISA = 'DBObject';
use strict qw(subs vars);

sub props
{
	my %props = (

		'url'	=> { 'type' => 'string', 'length' => 100, 'name' => 'Адрес в интернете (если есть)' },
		'name'	=> { 'type' => 'string', 'length' => 50, 'name' => 'Заглавие' },
		'context' => { 'type' => 'text', 'name' => 'Текст' },
		'str'	=> { 'type' => 'object', 'class' => 'Str', 'name' => 'Строка текста' }

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