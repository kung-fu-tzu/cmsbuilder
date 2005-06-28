# (с) Леонов П.А., 2005

package JDBI::CMS;
use strict qw(subs vars);
import JDBI;
import JIO;

sub _rpcs
{
	'cms_array_add'					=> [],
	'cms_admin_cre'					=> [],
	'cms_admin_edit'				=> [],
	'cms_array_elem_up'				=> [],
	'cms_array_elem_down'			=> [],
	'cms_array_elem_delete'			=> [],
	'cms_array_elem_moveto'			=> [],
	'cms_array_elem_move2'			=> [],
	'cms_array_elem_mkshcut'		=> [],
	'cms_array_sort'				=> [],
	'cms_chown'						=> [],
	''	=> [],
	''	=> [],
	''	=> [],
}


###################################################################################################
# Методы поддерживающие RPC
###################################################################################################

sub cms_chown
{
	my $o = shift;
	my $r = shift;
	
	my $uid = $r->{'uid'};
	my $tu;
	
	unless($JDBI::group->{'root'}){ $o->err_add('У Вас нет прав менять владельца элементам.'); return; }
	
	sess()->{'admin_refresh_left'} = 0;
	
	if($uid)
	{
		$uid =~ s/\D//g;
		
		$tu = User->new($uid);
		
		unless($tu->{'ID'}){ $o->err_add('Указанный пользователь не существует.'); return; }
		
		$o->ochown($uid);
		$o->save();
		$o->reload();
		
		$o->{'_do_list'} = 1;
		return;
	}
	
	my $nowu = User->new( $o->{'OID'} );
	
	print 'Изменение владельца для элемента: <b>',$o->name(),'</b><br>';
	print 'Текущий владелец элемента: <b>',$nowu->name(),'</b><br>';
	
	print '<br><br>Выберете нового владельца:<br><br>';
	
	my $count = 0;
	for $tu (User->sel_where(' 1 ORDER BY `name`'))
	{
		if($tu->{'ID'} == $nowu->{'ID'}){ next; }
		print $tu->admin_name('?act=cms_chown&url='.$o->myurl().'&uid='.$tu->{'ID'}),'<br>';
		$count++;
	}
	
	unless($count){ print '<center><b>Нет пользователей для отображения.</b></center>'; }
}

sub cms_array_sort
{
	my $o = shift;
	my $r = shift;
	
	unless($o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
	
	my $by = $r->{'by'};
	
	if($by eq 'reverse'){ $o->reverse(); }
	if($by eq 'class'){ $o->sortT('CLASS'); }
	if($by eq 'id'){ $o->sortT('ID'); }
	if($by eq 'num'){ $o->sortT('num'); }
	if($by eq 'ats'){ $o->update_ats_cts(); $o->sortT('ATS'); }
	if($by eq 'cts'){ $o->update_ats_cts(); $o->sortT('CTS'); }
	if($by eq 'name'){ $o->update_name(); $o->sortT('NAME'); }
	
	$o->{'_do_list'} = 1;
}

sub cms_array_elem_mkshcut
{
	my $o = shift;
	my $r = shift;
	
	my $elem = $o->elem($r->{'enum'});
	
	my $e_shcut = $elem->shcut_cre();
	$e_shcut->{'PAPA_ID'} = 0;
	unless($o->elem_can_paste($e_shcut))
	{
		print $e_shcut->papa();
		$e_shcut->del();
		return;
	}
	$o->elem_paste($e_shcut);
	$e_shcut->shcut_save();
	
	$o->{'_do_list'} = 1;
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
	
	unless($from->access('w')){ $from->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
	unless($elem->access('w')){ $from->err_add('У Вас нет разрешения изменять перемещаемый элемент.'); return; }
	
	if($uto)
	{
		my $to = JDBI::url($uto);
		unless($to->access('a')){ $from->err_add('У Вас нет разрешения добавлять в элемент назначения.'); return; }
		
		unless($to->elem_can_paste($elem)){ return; }
		
		$elem = $from->elem_cut($enum);
		$to->elem_paste($elem);
		
		$o->{'_do_list'} = 1;
		return;
	}
	
	sess()->{'admin_refresh_left'} = 0;
	
	print 'Выберите раздел, в который переместить элемент: <b>',ref($elem)->admin_name_ex('name' => $elem->name()),'</b>.<br><br>';
	
	my $count = 0;
	
	for my $c (@JDBI::classes,@JDBI::modules)
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
	
	unless($count){ print '<center><b>Нет разделов для отображения.</b></center>'; }
}

sub cms_array_elem_moveto
{
	my $o = shift;
	my $r = shift;
	$o->elem_moveto($r->{'enum'},$r->{'nnum'});
	
	$o->{'_do_list'} = 1;
}

sub cms_array_elem_delete
{
	my $o = shift;
	my $r = shift;
	$o->elem_del($r->{'enum'});
	
	$o->{'_do_list'} = 1;
}

sub cms_array_elem_up
{
	my $o = shift;
	my $r = shift;
	$o->elem_moveup($r->{'enum'});
	
	$o->{'_do_list'} = 1;
}

sub cms_array_elem_down
{
	my $o = shift;
	my $r = shift;
	$o->elem_movedown($r->{'enum'});
	
	$o->{'_do_list'} = 1;
}

sub cms_admin_cre
{
	my $o = shift;
	my $r = shift;
	
	if(!JDBI::classOK($r->{'cname'})){ return; }
	
	if(!$o->access('a')){ $o->err_add('У Вас нет разрешения добавлять в этот элемент.'); return; }
	
	my $to = $r->{'cname'}->cre();
	$to->admin_edit($r);
	$o->save();
	
	$o->elem_paste($to);
	
	$o->{'_do_list'} = 1;
}

sub cms_admin_edit
{
	my $o = shift;
	my $r = shift;
	
	my $tname = $o->name();
	$o->admin_edit($r);
	$o->save();
	$o->reload(); # Некоторые изменения, например ATS, OID, вступают в силу только после reload()
	if($tname eq $o->name()){ sess()->{'admin_refresh_left'} = 0; }
	
	$o->{'_do_list'} = 1;
}

sub cms_array_add
{
	my $o = shift;
	my $r = shift;
	
	unless(JDBI::classOK($r->{'cname'}))
	{
		$o->err_add('Класс <b>'.$r->{'cname'}.'</b> не существует.');
		return;
	}
	
	unless($o->access('a')){ $o->err_add('У Вас нет разрешения добавлять в этот элемент.'); return; }
	
	sess()->{'admin_refresh_left'} = 0;
	
	my $to = $r->{'cname'}->new();
	$to->admin_cre($o);
}

sub default
{
	my $o = shift;
	my $r = shift;
	
	unless($o->access('r')){ $o->err_add('У вас нет разрешений для просмотра этого элемента.'); return; }
	$o->{'_do_list'} = 1;
}

1;