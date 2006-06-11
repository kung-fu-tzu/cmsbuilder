# (�) ������ �.�., 2005

package CMSBuilder::DBI::CMS;
use strict qw(subs vars);

use CMSBuilder;
use CMSBuilder::IO;
use plgnUsers;

sub _rpcs
{qw/
cms_admin_cre cms_admin_edit

cms_array_elem_up cms_array_elem_down cms_array_add cms_array_elem_delete
cms_array_elem_moveto cms_array_elem_move2 cms_array_elem_mkshcut cms_array_sort
cms_array_elem_mkcopy cms_array_object_move cms_array_clear

cms_chown
/}


###################################################################################################
# ������ �������������� RPC
###################################################################################################

sub cms_chown
{
	my $o = shift;
	my $r = shift;
	
	my $uurl = $r->{'uurl'};
	
	unless($o->access('o')){ $o->err_add('� ��� ��� ���� ������ ��������� ���������.'); return; }
	
	if($uurl)
	{
		my $tu = cmsb_url($uurl);
		
		unless($tu->{'ID'}){ $o->err_add('��������� ������������ �� ����������.'); return; }
		
		$o->ochown($tu);
		$o->save();
		$o->reload();
		
		$o->{'_do_list'} = 1;
		return;
	}
	
	my $nowu = $o->owner;
	
	print
	'
	<fieldset><legend>��������� ��������� ��� ��������: ',$o->admin_name(),'</legend>
	<p>������� �������� ��������: <b>',$nowu->admin_name(),'</b><br>
	�������� ������ ���������:
	<p>
	<blockquote>
	';
	
	my $count = 0;
	for my $tu (map {$_->sel_where(' 1 ')} user_classes())
	{
		if($tu->myurl eq $nowu->myurl){ next; }
		print $tu->admin_name('?act=cms_chown&url='.$o->myurl().'&uurl='.$tu->myurl),'<br>';
		$count++;
	}
	
	unless($count){ print '��� ������������� ��� �����������.'; }
	
	print '</blockquote></p></p></fieldset>';
}

sub cms_array_sort
{
	my $o = shift;
	my $r = shift;
	
	unless($o->access('w')){ $o->err_add('� ��� ��� ���������� �������� ���� �������.'); return; }
	
	my $by = $r->{'by'};
	
	if($by eq 'reverse'){ $o->reverse(); }
	if($by eq 'class'){ $o->sortT('CLASS'); }
	if($by eq 'id'){ $o->sortT('ID'); }
	if($by eq 'num'){ $o->sortT('num'); }
	if($by eq 'ats'){ $o->update_ats_cts(); $o->sortT('ATS'); }
	if($by eq 'cts'){ $o->update_ats_cts(); $o->sortT('CTS'); }
	if($by eq 'name'){ $o->update_name(); $o->sortT('NAME'); }
	
	$o->{'_do_list'} = 1;
	$sess->{'admin_refresh_left'} = 1;
}

sub cms_array_clear
{
	my $o = shift;
	my $r = shift;
	
	unless($o->access('w')){ $o->err_add('� ��� ��� ���������� �������� ���� �������.'); return; }
	
	my $by = $r->{'by'};
	
	for my $i ($o->get_all()){ $o->elem_del(1) }
	
	$o->{'_do_list'} = 1;
	$sess->{'admin_refresh_left'} = 1;
}

sub cms_array_elem_mkshcut
{
	my $o = shift;
	my $r = shift;
	
	$o->{'_do_list'} = 1;
	
	my $elem = cmsb_url($r->{'turl'});
	
	my $e_shcut = $elem->shcut_cre();
	
	unless($o->elem_can_paste($e_shcut))
	{
		$o->err_add('���������� ��������� ����� ��� '.$elem->myurl().' � ������ '.ref($o).'.');
		$e_shcut->del();
		return;
	}
	$o->elem_paste($e_shcut);
	#$e_shcut->save();
	
	$sess->{'admin_refresh_left'} = 1;
}

sub cms_array_elem_mkcopy
{
	my $o = shift;
	my $r = shift;
	
	$o->{'_do_list'} = 1;
	
	my $elem = cmsb_url($r->{'turl'});
	
	my $e_copy = $elem->copy();
	
	unless($o->elem_can_paste($e_copy))
	{
		$e_copy->del();
		return;
	}
	$o->elem_paste($e_copy);
	
	$sess->{'admin_refresh_left'} = 1;
}

sub cms_array_object_move
{
	my $o = shift;
	my $r = shift;
	
	my $sact = $r->{'sact'};
	my $to = cmsb_url($r->{'ourl'});
	my $papa = $to->papa();
	
	unless($o->myurl() ne $to->myurl()){ return $o->err_add('������ ����������� ������� � ������ ����.'); }
	unless($o->access('w')){ return $o->err_add('� ��� ��� ���������� �������� ������ ����������.'); }
	
	if($sact eq 'move')
	{
		unless($to->access('w')){ return $o->err_add('� ��� ��� ���������� �������� ������������ �������.'); }
		unless($papa->access('w')){ return $o->err_add('� ��� ��� ���������� �������� ������, ���������� �������.'); }
	}
	unless($o->elem_can_paste($to)){ return $o->err_add('������� ������ '.ref($o).' �� ����� ��������� ������� ������ '.ref($to)); }
	
	if($sact eq 'copy')
	{
		$to = $to->copy();
		$o->elem_paste($to);
		
		$r->{'pos'}++;
	}
	
	if($sact eq 'shcut')
	{
		$to = $to->shcut_cre();
		$o->elem_paste($to);
		
		$r->{'pos'}++;
	}
	
	if($sact eq 'move')
	{
		if($to->enum())
		{
			if($papa->myurl() ne $o->myurl())
			{
				$papa->elem_cut($to->enum());
				$o->elem_paste($to);
			}
		}
		else
		{
			$o->elem_paste($to);
		}
	}
	
	if($r->{'page'} ne '')
	{
		my $npos = $r->{'page'}*$o->array_onpage();
		
		if($papa && $papa->myurl() eq $o->myurl() && $to->enum() < $r->{'page'}*$o->array_onpage())
		{
			$npos++;
		}
		
		$o->elem_moveto($to->enum(),$npos);
	}
	
	if($r->{'pos'} ne '')
	{
		$o->elem_moveto($to->enum(),$r->{'pos'});
	}
	
	print
	'
	<script>
	parent.admin_right.SafeRefresh();
	parent.admin_left.SafeRefresh();
	</script>
	';
}

sub cms_array_elem_move2
{
	my $o = shift;
	my $r = shift;
	
	my $url = $o->myurl();
	my $uto = $r->{'to'};
	my $enum = $r->{'enum'};
	
	my $from = $o;
	my $elem = $from->elem($enum);
	
	unless($from->access('w')){ $from->err_add('� ��� ��� ���������� �������� ������, ���������� �������.'); return; }
	unless($elem->access('w')){ $from->err_add('� ��� ��� ���������� �������� ������������ �������.'); return; }
	
	if($uto)
	{
		my $to = cmsb_url($uto);
		unless($to->access('a')){ $from->err_add('� ��� ��� ���������� ��������� � ������� ����������.'); return; }
		
		unless($to->elem_can_paste($elem)){ return; }
		
		$elem = $from->elem_cut($enum);
		$to->elem_paste($elem);
		
		$o->{'_do_list'} = 1;
		$sess->{'admin_refresh_left'} = 1;
		return;
	}
	
	print '�������� ������, � ������� ����������� �������: <b>',$elem->admin_name(),'</b>.<br><br>';
	
	my $count = 0;
	
	for my $c (cmsb_allclasses())
	{
		unless( $c->elem_can_add(ref($elem)) ){ next; }
		
		for my $d ($c->sel_where(' 1 '))
		{
			unless($d->elem_can_paste($elem)){ next; }
			unless($d->access('a')){ next; }
			
			print $d->admin_name('?url='.$from->myurl().'&act=cms_array_elem_move2&to='.$d->myurl().'&enum='.$enum),'<br>';
			$count++;
		}
	}
	
	unless($count){ print '<center><b>��� �������� ��� �����������.</b></center>'; }
}

sub cms_array_elem_moveto
{
	my $o = shift;
	my $r = shift;
	$o->elem_moveto($r->{'enum'},$r->{'nnum'});
	
	$o->{'_do_list'} = 1;
	$sess->{'admin_refresh_left'} = 1;
}

sub cms_array_elem_delete
{
	my $o = shift;
	my $r = shift;
	$o->elem_del($r->{'enum'});
	
	$o->{'_do_list'} = 1;
	$sess->{'admin_refresh_left'} = 1;
}

sub cms_array_elem_up
{
	my $o = shift;
	my $r = shift;
	$o->elem_moveup($r->{'enum'});
	
	$o->{'_do_list'} = 1;
	$sess->{'admin_refresh_left'} = 1;
}

sub cms_array_elem_down
{
	my $o = shift;
	my $r = shift;
	$o->elem_movedown($r->{'enum'});
	
	$o->{'_do_list'} = 1;
	$sess->{'admin_refresh_left'} = 1;
}

sub cms_admin_cre
{
	my $o = shift;
	my $r = shift;
	
	unless(cmsb_classOK($r->{'cname'})){ return; }
	
	unless($o->access('a')){ $o->err_add('� ��� ��� ���������� ��������� � ���� �������.'); return; }
	
	my $to = $r->{'cname'}->cre();
	$to->admin_edit($r);
	$o->save();
	
	$o->elem_paste($to);
	
	if($r->{'wdo'} eq 'add')
	{
		print '<script>window.setTimeout(\'location.href="right.ehtml?url=',$to->myurl(),'"\',700,"JavaScript");</script>';
	}
	elsif($r->{'wdo'} eq 'ok')
	{
		$o->{'_do_list'} = 1;
	}
	else
	{
		
	}
	
	$o->admin_array_selectedpage({'page' => $o->pages()-1});
	
	$sess->{'admin_refresh_left'} = 1;
}

sub cms_admin_edit
{
	my $o = shift;
	my $r = shift;
	
	my $tname = $o->name();
	$o->admin_edit($r);
	$o->save();
	$o->reload(); # ��������� ���������, �������� ATS, OWNER, �������� � ���� ������ ����� reload()
	if($tname ne $o->name()){ $sess->{'admin_refresh_left'} = 1; }
	
	if($r->{'wdo'} eq 'ok')
	{
		if($o->papa())
		{
			print '<script>window.setTimeout(\'location.href="right.ehtml?url=',$o->papa()->myurl(),'"\',700,"JavaScript");</script>';
		}
		else
		{
			$o->{'_do_list'} = 1;
		}
	}
	elsif($r->{'wdo'} eq 'save')
	{
		$o->{'_do_list'} = 1;
	}
	else
	{
		
	}
}

sub cms_array_add
{
	my $o = shift;
	my $r = shift;
	
	unless(cmsb_classOK($r->{'cname'}))
	{
		$o->err_add('����� <b>'.$r->{'cname'}.'</b> �� ����������.');
		return;
	}
	
	unless($o->access('a')){ $o->err_add('� ��� ��� ���������� ��������� � ���� �������.'); return; }
	
	my $to = $r->{'cname'}->new();
	$to->admin_cre($o);
}

sub default
{
	my $o = shift;
	my $r = shift;
	
	unless($o->access('r')){ $o->err_add('� ��� ��� ���������� ��� ��������� ����� ��������.'); return; }
	
	$o->{'_do_list'} = 1;
}

1;