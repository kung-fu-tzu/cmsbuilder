# (с) Леонов П.А., 2005

package CMSBuilder::DBI::Array::AAdmin;
use strict qw(subs vars);
use utf8;

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder;
use CMSBuilder::IO;

sub admin_cmenu_for_self
{
	my $o = shift;
	
	my $code = $o->CMSBuilder::DBI::Object::admin_cmenu_for_self(@_);
	
	if($o->access('w'))
	{
		$code .=
		'
		
		smenu = JMenu();
		with(smenu)
		{
			elem_add(JTitle("Сортировать"));
		';
		if($o->len())
		{
			$code .=
			'
			elem_add(JMIHref("По имени","right.ehtml?url='.$o->myurl().'&act=cms_array_sort&by=name"));
			elem_add(JMIHref("Обратить","right.ehtml?url='.$o->myurl().'&act=cms_array_sort&by=reverse"));
			elem_add(JMIHref("По типу","right.ehtml?url='.$o->myurl().'&act=cms_array_sort&by=class"));
			elem_add(JMIHref("Создан","right.ehtml?url='.$o->myurl().'&act=cms_array_sort&by=cts"));
			elem_add(JMIHref("Изменён","right.ehtml?url='.$o->myurl().'&act=cms_array_sort&by=ats"));
			elem_add(JHR());
			';
		}
		$code .=
		'
			elem_add(JMIHref("По ID","right.ehtml?url='.$o->myurl().'&act=cms_array_sort&by=id"));
			elem_add(JMIHref("Починить","right.ehtml?url='.$o->myurl().'&act=cms_array_sort&by=num"));
		}
		smenu_i = elem_add(JMISubMenu("Сортировать",smenu));
		';

		$code .= 'elem_add(JMIConfirm("Очистить","right.ehtml?url='.$o->myurl().'&act=cms_array_clear","","Удалить '.$o->len().' элементов?"));' if $o->len()
	}
	
	return $code;
}

sub admin_cmenu_for_son
{
	my $o = shift;
	my $son = shift;
	my $code;
	
	if($o->access('w'))
	{
		$code .=
		'
		elem_add(JHR());
		elem_add(JMIHref("Копия...","right.ehtml?url='.$o->myurl().'&act=cms_array_elem_mkcopy&turl='.$son->myurl().'"));
		elem_add(JMIHref("Ярлык...","right.ehtml?url='.$o->myurl().'&act=cms_array_elem_mkshcut&turl='.$son->myurl().'"));
		';
		
		if($son->enum())
		{
			$code .=
			'
			elem_add(JMIHref("Переместить...","right.ehtml?url='.$o->myurl().'&act=cms_array_elem_move2&enum='.$son->enum().'"));
			elem_add(JMIConfirm("Удалить","right.ehtml?url='.$o->myurl().'&act=cms_array_elem_delete&enum='.$son->enum().'","","Удалить \"'.$son->name().'\"?"));
			';
		}
	}
	
	return $code;
}

sub admin_left_tree
{
	my $o = shift;
	
	my %ret = %{$o->CMSBuilder::DBI::Object::admin_left_tree(@_)};
	
	if($o->{'SHCUT'}){ return {%ret}; }
	
	my @elems;
	
	for my $to ($o->get_interval(1,$CMSBuilder::Config::admin_max_left))
	{
		if($to->dont_list_me()){ next; }
		push @elems, $to->admin_left_tree();
	}
	
	if($o->len() > $CMSBuilder::Config::admin_max_left)
	{
		push @elems, {-name => '<font style="cursor: pointer" onclick="alert(\'Количество элементов, отображаемых в левой панели, ограничено. Вы можете продолжать добавлять элементы. Они будут доступны в правой панели - по '.($o->array_onpage()||$CMSBuilder::Config::array_def_on_page).' на странице.\')" color="#ff7300" size=1>&nbsp;Элементы перечислены не полностью...</font>', -id => 'to_many'};
	}
	
	return {%ret, -elems => \@elems};
}

sub admin_view
{
	my $o = shift;
	
	$o->admin_array_view(@_);
	$o->CMSBuilder::DBI::Object::admin_view(@_);
}

sub admin_array_view
{
	my $o = shift;
	my $r = shift;
	
	unless($o->access('r')){ return; }
	
	my $page = $o->admin_array_selectedpage($r);
	
	my $dsp = {CGI::cookie('aview_elems')}->{'s'} eq '0'?0:1;
	
	print
	'
	<fieldset>
	<legend onmousedown="ShowHide(aview_elems,treenode_aview_elems)"><span class="objtbl"><img class="ticon" id="treenode_aview_elems" src="img/'.($dsp?'minus':'plus').'.gif"><span class="subsel">Список вложенных элементов</span></span></legend>
	<div class="padd" id="aview_elems" style="display:'.($dsp?'block':'none').'">
	';

	
	print
	'
	<table width="100%"><tr><td width="60%" valign="top">
	
	';
	
	my @pagea = $o->get_page($page);
	
	if(@pagea)
	{
		print '<table class="admin_array_view"><tr><td myurl="',$o->myurl(),'" elempos="',($pagea[0]->enum()-1),'" cms_ondragover="this.className = \'dragline\';" ondragover="return CMS_GlobalDragOver(this)" ondrop="return CMS_GlobalDrop(this)" ondragleave="this.className = \'\';">&nbsp;</td></tr>';
		
		for my $e (@pagea)
		{
			unless($o->access('r')){ next; }
			
			print '<tr><td myurl="',$o->myurl(),'" elempos="',$e->enum(),'" cms_ondragover="this.className = \'dragline\';" ondragover="return CMS_GlobalDragOver(this)" ondrop="return CMS_GlobalDrop(this)" ondragleave="this.className = \'\';">';
			
			$e->admin_arrayline($o);
			
			print $e->admin_name();
			
			print '</td></tr>';
			print "\n";
		}
		
		print '</table>';
	}
	else
	{
		print '<p align="center">Нет элементов.</p>';
	}
	
	$o->admin_array_pagesline($r);
	
	print '</td><td valign="top">';
	$o->admin_add_list();
	print '</td></tr></table></div></fieldset>';
}

sub admin_array_pagesline
{
	my $o = shift;
	my $r = shift;
	
	if($o->pages() < 2){ return; }
	
	my $page = $o->admin_array_selectedpage($r);
	
	print '<p align="center"><table class="pagesline"><tr>';
	
	my($href,$drag);
	for(my $p=0;$p<$o->pages();$p++)
	{
		$href = '?url='.$o->myurl().'&page='.$p;
		$drag = 'myurl="'.$o->myurl().'" elempos="&page='.$p.'" ondragover="return CMS_GlobalDragOver(this)" ondrop="return CMS_GlobalDrop(this)" cms_ondragenter="if(!this.dclassName) this.dclassName=this.className; this.className = \'drag\';" ondragleave="this.className = this.dclassName;"';
		
		if($p == $page)
		{
			print '<td class="current" '.$drag.'>'.($p+1).'</td>';
		}
		else
		{
			print '<td onclick="location.href=\''.$href.'\'" class="other" '.$drag.'>'.($p+1).'</td>';
		}
	}
	
	print '</tr></table></p>';
}

sub admin_array_selectedpage
{
	my $o = shift;
	my $r = shift;
	
	my $page = $r->{'page'};
	
	unless(defined $page){ $page = $sess->{$o->myurl().'.page'} || 0; }
	else{ $sess->{$o->myurl().'.page'} = $page; }
	
	return $page;
}

sub admin_add_list
{
	my $o = shift;
	
	unless($o->access('a')){ return; }
	
	print
	'
	<fieldset>
	<legend align="center">Создать</legend>
	<div class="padd">
	';
	
	my $cnt;
	for my $cn (cmsb_classes())
	{
		unless($o->elem_can_add($cn)){ next; }
		if($cn->one_instance()){ next; }
		print $cn->admin_cname('','right.ehtml?url='.$o->myurl().'&act=cms_array_add&cname='.$cn),'&nbsp;';
		$cnt++;
	}
	
	unless($cnt){ print 'Нет классов.'; };
	
	print '</div></fieldset>';
}


1;