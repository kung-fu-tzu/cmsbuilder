# (�) ������ �.�., 2005

package modUsers;
use strict qw(subs vars);
our @ISA = 'CMSBuilder::DBI::TreeModule';

sub _cname {'������������'}
sub _add_classes {qw/UserGroup/}
sub _one_instance {1}
sub _have_icon {1}

sub _props
{
	'name'	=> { 'type' => 'string', 'length' => 50, 'name' => '��������' },
}

#-------------------------------------------------------------------------------


sub install_code
{
	my $mod = shift;
	my($mr,$tm,$tg,$tu);
	$mr = modRoot->new(1);
	
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
	$tu->save();
	$tg->elem_paste($tu);
	
	$tu = User->cre();
	$tu->{'name'}   = '����������';
	$tu->{'login'}  = 'barmental';
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

1;