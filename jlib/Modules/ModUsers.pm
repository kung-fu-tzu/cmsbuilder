package ModUsers;
use strict qw(subs vars);
our @ISA = 'StdModule';

our $name = '������������';
our @classes = qw/UserGroup User/;

our $page = '/page';
our $pages_direction = 1;
our $add  = ' UserGroup ';
our @aview = qw/name/;
our $icon = 1;
our $one_instance = 1;

our %props = (
	'name'		=> { 'type' => 'string', 'length' => 50, 'name' => '��������' }
);

sub install_code
{
	my $mod = shift;
	my($mr,$tm,$tg,$tu);
	$mr = ModRoot->new(1);
	
	$tm = $mod->cre();
	$tm->{'name'} = '������������';
	$tm->save();
	$mr->elem_paste($tm);
	
	$tg = UserGroup->cre();
	$tg->{'name'}   = '��������������';
	$tg->{'html'}   = 1;
	$tg->{'files'}  = 1;
	$tg->{'cms'}	= 1;
	$tg->{'root'}   = 1;
	$tg->{'cpanel'} = 1;
	$tg->save();
	
	$tm->elem_paste($tg);
	
	$tu = User->cre();
	$tu->{'name'}   = '�������������';
	$tu->{'login'}  = 'admin';
	$tu->{'pas'}	= 'admin';
	$tu->save();
	$tg->elem_paste($tu);
	
	
	$tg = UserGroup->cre();
	$tg->{'name'}   = '�����';
	$tg->save();
	
	$tm->elem_paste($tg);
	
	$tu = User->cre();
	$tu->{'name'}   = '�����';
	$tu->save();
	
	$tg->elem_paste($tu);
	
}

return 1;