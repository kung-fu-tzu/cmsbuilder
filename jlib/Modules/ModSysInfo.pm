# (�) ������ �.�., 2005

package ModSysInfo;
use strict qw(subs vars);
our @ISA = 'JDBI::SimpleModule';

sub _cname {'��������� ����������'}
sub _one_instance {1}
sub _have_icon {0}

sub _rpcs
{
	'list_dbocache' => ['��� ��������',''],
	'tree' => ['������','Page.gif'],
}

sub _props
{
	'name'	=> { 'type' => 'string', 'length' => 50, 'name' => '��������' }
}

#-------------------------------------------------------------------------------


sub tree
{
	my $o = shift;
	$o->admin_view();
}

sub list_dbocache
{
	for my $t (keys(%JDBI::dbo_cache))
	{
		print $JDBI::dbo_cache{$t},' -> ',$JDBI::dbo_cache{$t}->name(),'<br>';
	}	
}

sub default
{
	print '�������� ����������� �������� ������.';
}

1;