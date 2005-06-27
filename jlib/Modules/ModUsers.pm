# (с) Леонов П.А., 2005

package ModUsers;
use strict qw(subs vars);
our @ISA = 'JDBI::TreeModule';

sub _cname {'Пользователи'}
sub _classes {qw/UserGroup User/}
sub _add_classes {qw/UserGroup/}
sub _one_instance {1}

sub _props
{
	'name'	=> { 'type' => 'string', 'length' => 50, 'name' => 'Название' },
}

#-------------------------------------------------------------------------------


sub install_code
{
	my $mod = shift;
	my($mr,$tm,$tg,$tu);
	$mr = ModRoot->new(1);
	
	$tm = $mod->cre();
	$tm->{'name'} = 'Пользователи';
	$tm->save();
	$mr->elem_paste($tm);
	
	$tg = UserGroup->cre();
	$tg->{'name'}   = 'Администраторы';
	$tg->{'html'}   = 1;
	$tg->{'files'}  = 1;
	$tg->{'cms'}	= 1;
	$tg->{'root'}   = 1;
	$tg->{'cpanel'} = 1;
	$tg->save();
	
	$tm->elem_paste($tg);
	
	$tu = User->cre();
	$tu->{'name'}   = 'Администратор';
	$tu->{'login'}  = 'admin';
	$tu->{'pas'}	= 'admin';
	$tu->save();
	$tg->elem_paste($tu);
	
	
	$tg = UserGroup->cre();
	$tg->{'name'}   = 'Гости';
	$tg->save();
	
	$tm->elem_paste($tg);
	
	$tu = User->cre();
	$tu->{'name'}   = 'Гость';
	$tu->save();
	
	$tg->elem_paste($tu);
}

1;