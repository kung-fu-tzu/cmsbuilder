package ModHttp;
use strict qw(subs vars);
our @ISA = 'StdModule';

our $name = 'Сайт';
our @classes = qw/Elem Papa Dir/;

our $page = '/page';
our $pages_direction = 1;
our $add  = ' Elem Dir Papa ';
our @aview = qw/name dolist/;
our $icon = 1;

our %props = (
	'name'		=> { 'type' => 'string', 'length' => 50, 'name' => 'Название' },
	'dolist'	=> { 'type' => 'checkbox', 'name' => 'Отображать' }
);

sub install_code
{
	my $mod = shift;
	
	my $mr = ModRoot->new(1);
	
	my $to = $mod->cre();
	$to->{'name'} = 'Сайт';
	$to->save();
	
	$mr->elem_paste($to);
}

return 1;