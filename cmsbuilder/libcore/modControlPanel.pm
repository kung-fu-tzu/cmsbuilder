# (�) ������ �.�., 2005

package modControlPanel;
use strict qw(subs vars);
our @ISA = ('CMSBuilder::DBI::SimpleModule');

use CMSBuilder;
use CMSBuilder::Utils;
use plgnUsers;

sub _cname {'������ ����������'}
sub _have_icon {1}
sub _one_instance {1}
sub _rpcs {qw/cpanel_table_cre/, keys %{{_simplem_menu()}}}

sub _simplem_menu
{
	'cpanel_table_fix'		=> { -name => '�������� ���������...', -icon => 'icons/table.gif' },
	'cpanel_object_stat'	=> { -name => '���������� ��������', -icon => 'icons/install.gif' },
	'cpanel_install_mods'	=> { -name => '��������� ������...', -icon => 'icons/install.gif' },
	'cpanel_mod_root1'		=> { -obj => 'modRoot1' },
	$CMSBuilder::Config::server_type eq 'cgi-server'?
	('cpanel_stopserver'		=> { -name => '���������� ������', -icon => 'icons/shutdown.gif' }):(),
}

#-------------------------------------------------------------------------------


our	$refresh;

sub default
{
	print '������ "������ ����������" �������� ��� �������������� ����������� ������� � �������� ���������������� ����������.';
}

sub mod_is_installed { return 1; }
sub install_code {}

sub cpanel_stopserver
{
	my $pid = f2var($CMSBuilder::Config::server_pidfile);
	
	warn "Kiling server, pid: $pid";
	
	if(kill('KILL' => $pid)){ print "������ ������� ���������� (KILL => $pid)."; }
	else{ print "������ ���������� �� ������� ($pid)."; }
}

sub admin_view_left
{
	my $o = shift;
	
	unless(modRoot->table_have())
	{
		print '<br><center>��������� ���� �� �����������!</center>';
		return;
	}
	
	return $o->SUPER::admin_view_left(@_);
}

sub admin_view_right
{
	my $o = shift;
	
	unless($group->{'root'})  { CMSBuilder::IO::err403('Trying to cpanel, less $group->{"root"}'); return; }
	unless($group->{'cpanel'}){ CMSBuilder::IO::err403('Trying to cpanel, less $group->{"cpanel"}'); return; }
	
	$refresh = 0;
	
	my @res = $o->SUPER::admin_view_right(@_);
	
	unless(modRoot->table_have())
	{
		print '<br><br>��������� ���� �� �����������! <a href="?url=',$o->myurl(),'&act=cpanel_table_cre"><b>����������...</b></a>';
		return;
	}
	
	if($refresh){ print '<script language="JavaScript">parent.frames.admin_modules.document.location.href = parent.frames.admin_modules.document.location.href;</script>'; }
	
	return @res;
}

sub cpanel_scanbase
{
	my $o = shift;
	
	for my $cn (cmsb_allclasses())
	{
		for my $to ($cn->sel_where(" PAPA_CLASS = '' OR PAPA_ID = 0 "))
		{
			print $to->name(),'<br>';
		}
	}
}

sub cpanel_table_cre
{
	my $o = shift;
	
	CMSBuilder::DBI::access_creTABLE();
	modRoot->table_cre();
	my $mr = modRoot->cre();
	$mr->{'name'} = '������ �������';
	$mr->papa_set($o);
	$mr->save();
	
	cpanel_table_fix();
	
	print
	'
	<p>������� ���� �������, ������� ���������� � ������ ������� ������� �����������.</p>
	<p>������, ��������� ��� &#151; ��� <a href="'.$o->admin_right_href().'&act=cpanel_install_mods"><u>��������� �������</u></a>.</p>
	';
	$refresh = 1;
}

sub cpanel_table_fix
{
	my $ch;
	for my $cn (cmsb_allclasses())
	{
		my $log = $cn->table_fix();
		
		print '<div><small style="float:right">';
		
		if($log->{'changed'} || $log->{'existed'} || $log->{'deleted'})
		{
			if($log->{'changed'})
			{
				print join ', ', map { '<strong>~'.$_->{'name'}.'</strong>[ '.$_->{'from'}.' &rarr; '.$_->{'to'}.' ]' } @{$log->{'changed'}};
			}
			if($log->{'existed'})
			{
				print join ', ', map { '<strong>+'.$_->{'name'}.'</strong>[ '.$_->{'to'}.' ]' } @{$log->{'existed'}};
			}
			if($log->{'deleted'})
			{
				print join ', ', map { '<strong>-'.$_->{'name'}.'</strong>[ '.$_->{'from'}.' ]' } @{$log->{'deleted'}};
			}
		}
		else
		{
			print '�������';
		}
		
		print '</small>',$cn->admin_cname(),'</div>';
		
		$ch += keys %$log;
	}
	
	print '<p>';
	if($ch){ print '��������� ���������.'; }
	else{ print '���������� �� ���������.'; }
	print '</p>';
}

sub cpanel_object_stat
{
	print '<br><table><tr><td align="center"><b>�����</b></td><td width="25">&nbsp;</td><td><b>���-��</b></td></tr>';
	
	for my $mod (@CMSBuilder::modules,'',@CMSBuilder::classes)
	{
		unless($mod){ print '<tr><td>&nbsp;</td><td></td><td></td></tr>'; next; }
		
		print '<tr><td>',$mod->admin_cname(),'</td><td></td><td align="center">',(${$mod.'::simple'}?'-':$mod->count()),'</td></tr>';
	}
	
	print '</table>';
}

sub cpanel_install_mods
{
	my $some = 0;
	
	for my $mod (@CMSBuilder::modules)
	{
		$some |= $mod->install();
		$mod->err_print();
	}
	
	if($some){ print '<br>������ ������� �����������.'; } #$refresh = 1;
	else{ print '<br>��������� �� ���������.'; }
}


1;