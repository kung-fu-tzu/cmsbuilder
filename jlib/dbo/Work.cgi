package Work;

$name = 'Работа';
@ISA = 'DBObject';

sub props
{
	my %props = (

		url	=> { type => string, length => 100, name => 'Адрес в интернете' },
		name	=> { type => string, length => 50, name => 'Название работы' },
		img	=> { type => file, mime => 'image/jpeg', msize => 1024*500, ext => '.jpg', name => 'Маленькая картинка' },
		big	=> { type => file, mime => 'image/jpeg', msize => 1024*1024, ext => '.jpg', name => 'Большая картинка' },
		context => { type => text, name => 'Краткое пояснение' },
		tobj => { type => object, class => 'Text', name => 'Текстовый объект' }
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