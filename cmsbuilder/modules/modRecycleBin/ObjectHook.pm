# CMSBuilder © Леонов П. А., 2005-2006

package modRecycleBin::ObjectHook;
use strict qw(subs vars);
use utf8;

use CMSBuilder;
use CMSBuilder::IO;
use modUsers::API;

sub _rpcs
{
	cms_move_to_recyclebin			=> {},
	cms_restore_from_recyclebin		=> {},
}

#-------------------------------------------------------------------------------

sub cms_restore_from_recyclebin
{
	my $o = shift;
	
	return print('<script>alert("Неизвестно исходное местоположение елемента.")</script>') unless exists $sess->{$o->modrecyclebin_sesskey};
	my $oldp = cmsb_url($sess->{$o->modrecyclebin_sesskey}) || return print '<script>alert("Исходное местоположение елемента не существует.")</script>';
	
	my $rb = $o->papa || return;
	$rb->elem_cut($o);
	
	unless($oldp->elem_paste($o))
	{
		$rb->elem_paste($o);
		return $o->err_add('Не удаётся переместить елемент в исходное местоположение.');
	}
	
	delete $sess->{$o->modrecyclebin_sesskey};
	
	print
	'
	<script>
	parent.admin_right.SafeRefresh();
	parent.admin_left.SafeRefresh();
	</script>
	';
}

sub cms_move_to_recyclebin
{
	my $o = shift;
	my $r = shift;
	
	my $rb = $user->{'recyclebin'} || die "Cannot cms_move_to_recyclebin() whitout $user->{'recyclebin'}";
	
	
	if(my $papa = $o->papa)
	{
		return $o->err_add('Не удалось вырезать элемент.') unless $papa->elem_cut($o);
		
		$sess->{$o->modrecyclebin_sesskey} = $papa->myurl;
	}
	
	$rb->elem_paste($o);
	
	print
	'
	<script>
	parent.admin_right.SafeRefresh();
	parent.admin_left.SafeRefresh();
	</script>
	';
}

sub modrecyclebin_sesskey
{
	my $o = shift;
	
	return 'modRecycleBin ' . $o->myurl;
}


1;