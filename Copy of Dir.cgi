package Dir;
$name = 'Директория';
$page = '/page.ehtml';
$pages_direction = 0;
#@aview = qw/name onpage/;
$add  = ' Elem Dir Papa ';
@ISA = 'DBArray';
$dont_list_me = 0;
use strict qw(subs vars);

my %props = (

	'name'	  => { 'type' => 'string', 'length' => 100, 'name' => 'Название' },
	'onpage'  => { 'type' => 'int', 'name' => 'Элементов на странице' }
);

sub props
{
	my $o = shift;
	my %tprops = $o->SUPER::props();
	
	my $key;
	
	for $key (keys(%props)){
		
		if($tprops{$key}){ eml::err505('PROPS: overlaying "'.$key.'" by class "'.ref($o).'"'); }
		
		$tprops{$key} = $props{$key};
	}
	
	return %tprops;
}

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