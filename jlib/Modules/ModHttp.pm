# (с) Леонов П.А., 2005

package ModHttp;
use strict qw(subs vars);
our @ISA = 'JDBI::TreeModule';

sub _cname {'Сайт'}
sub _classes {qw/Elem Papa Dir/}
sub _add_classes {qw/Elem Dir Papa ShortCut/}

sub _props
{
	'name'	=> { 'type' => 'string', 'length' => 50, 'name' => 'Название' },
}

#-------------------------------------------------------------------------------


sub install_code
{
	my $mod = shift;
	
	my $mr = ModRoot->new(1);
	
	my $to = $mod->cre();
	$to->{'name'} = $mod->cname();
	$to->save();
	
	$mr->elem_paste($to);
}

1;