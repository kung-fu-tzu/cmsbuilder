package JDBI::Admin;
use CGI ('param');
use JDBI;
use strict qw(subs vars);


###################################################################################################
# Методы автоматизации администрирования
###################################################################################################

sub admin_left
{
	my $o = shift;
	
	print '<nobr><img align="absmiddle" src="img/nx.gif">',$o->admin_name(),'</nobr><br>',"\n";
}

sub admin_arrayline
{
	my $o = shift;
	my $a = shift;
	my $page = shift;
	
	my $enum = $o->enum();
	
	print( ($enum != $a->len())?'<a href="?url='.$a->myurl().'&act=edown&enum='.$enum.'&page='.$page.'"><img border=0 align="absmiddle" alt="Переместить ниже" src="img/down.gif"></a>':'<img align="absmiddle" src="img/nx.gif">' );
	print( ($enum != 1)?'<a href="?url='.$a->myurl().'&act=eup&enum='.$enum.'&page='.$page.'"><img border=0 align="absmiddle" alt="Переместить выше" src="img/up.gif"></a>':'<img align="absmiddle" src="img/nx.gif">' );
}

sub admin_hicon {}

sub admin_name
{
	my $o = shift;
	my $href = shift || $o->admin_right_href();
	my $targ = shift || 'admin_right';
	my ($ret,$icon,$myurl);
	
	$ret = $o->name();
	$ret =~ s/\<(?:.|\n)+?\>//g;
	if(!$ret){ $ret = ${ref($o).'::name'}.' без имени' }
	if(length($ret) > $JConfig::admin_max_left_name_len){ $ret = substr($ret,0,$JConfig::admin_max_left_name_len-1).'...' }
	
	$icon = $o->admin_hicon().'<img align="absmiddle" src="'.$o->admin_icon().'">';
	$myurl = $o->myurl();
	return '<nobr id="cmenu_'.$myurl.'" ondragstart="drag_start_num = '.$o->enum().'; return OnDragStart(cmenu_'.$myurl.')" oncontextmenu="return OnContext(cmenu_'.$myurl.')" style="CURSOR: default">'.$icon.'&nbsp;<span style="CURSOR: default" id="id_'.$myurl.'">&nbsp;<a target="'.$targ.'" href="'.$href.'">'.$ret.'</a>&nbsp;</span></nobr>';
}

sub admin_cname
{
	my $c = shift;
	my $name = shift || ${$c.'::name'};
	my $href = shift;
	return '<nobr style="CURSOR: default"><img align="absmiddle" src="'.$c->admin_icon().'">&nbsp;&nbsp;'.($href?'<a href="'.$href.'">':'').$name.($href?'</a>':'').'</nobr>'
}

sub admin_pname
{
	my $o = shift;
	my ($ret,$icon,$myurl);
	
	$ret = $o->name();
	$ret =~ s/\<(?:.|\n)+?\>//g;
	if(!$ret){ $ret = ${ref($o).'::name'}.' без имени' }
	if(length($ret) > $JConfig::admin_max_left_name_len){ $ret = substr($ret,0,$JConfig::admin_max_left_name_len-1).'...' }
	
	$icon = $o->admin_hicon().'<img align="absmiddle" src="'.$o->admin_icon().'">';
	$myurl = $o->myurl();
	return '<nobr style="CURSOR: default">'.$icon.'&nbsp;&nbsp;'.$ret.'&nbsp;</nobr>';
}

sub admin_icon
{
	my $o = shift;
	my $class = ref($o) || $o;
	
	if( ${$class.'::icon'} ){ return 'icons/'.$class.'.gif'; }
	return 'icons/default.gif';
}

sub admin_right_href
{
	my $o = shift;
	return 'right.ehtml?url='.$o->myurl();
}

sub admin_cmenu
{
	my $o = shift;
	if(!$o->access('r')){ print 'all_menus["',$o->myurl(),'"] = JMenu();'; return; }
	
	print 'all_menus_code["',$o->myurl(),'"] = \'';
	
	print 'all_menus.',$o->myurl(),' = JMenu();';
	print 'with(all_menus.',$o->myurl(),'){';
	
	my $title = $o->admin_pname();
	$title =~ s/"/\\\\\\"/g;
	print 'elem_add(JTitle("'.$title.'"));';
	
	$o->admin_cmenu_for_self();
	
	my $papa = $o->papa();
	if($papa){ $papa->admin_cmenu_for_son($o); }
	
	print '}\';';
}

sub admin_cmenu_for_self
{
	my $o = shift;
	
	if($o->access('r')){
		print 'elem_add(JMIHref("Открыть","',$o->admin_right_href(),'"));';
	}
	
	if($o->access('c')){
		print 'elem_add(JMIHref("Разрешения...","right.ehtml?url=',$o->myurl(),'&act=chmod"));';
	}
}

sub admin_cmenu_for_son { }

sub admin_tree
{
	my $o = shift;
	my $to;
	$to = $o;
	
	my @tree;
	my @names;
	my $count = 0;
	
	print '<script>
	if(CMS_HaveParent()){
	
	';
	
	do{
		$count++;
		push(@tree, $to);
		
	}while( $to = $to->papa() and $count < 50 );
	
	
	for $to (reverse @tree){
		push(@names, $to->admin_name());
		print 'parent.frames.admin_left.CMS_SelectLO("id_'.$to->myurl().'");';
		print 'parent.frames.admin_left.CMS_ShowMe("'.$to->myurl().'");';
	}
	
	print '
	}
	</script>';
	
	print '<textarea style="DISPLAY: none" id="tree_div">',join(' / ',@names),'</textarea>';
}

sub admin_edit
{
	my $o = shift;
	my ($key,$val,@keys,$vtype);
	my $p = \%{ ref($o).'::props' };
	
	if($o->{'ID'} < 1){ $o->err_add('Объект не существует.'); return; }
	
	if( $#{ ref($o).'::aview' } > -1 ){ @keys = @{ ref($o).'::aview' }; }else{ @keys = keys( %$p ); }
	
	for $key (@keys){
		
		$val = param($key);
		$vtype = 'JDBI::vtypes::'.$p->{$key}{'type'};
		
		if(!$JDBI::group->{'html'} and !${$vtype.'::dont_html_filter'}){ $val = JDBI::HTMLfilter($val); }
		
		$val = $vtype->aedit($key,$val,$o);
		
		$o->{$key} = $val;
	}
	
	if($o->err_is()){ $o->{'_print'} = "Изменения частично внесены.<br>\n"; }
	else{ $o->{'_print'} = "Изменения успешно внесены.<br>\n"; }
}

sub admin_cre
{
	my $o = shift;
	my $where = shift;
	
	$o->{'_print'} = 'Создание элемента...';
	$o->admin_err_print();
	
	print '<p class="hr">Данные элемента:</p>';
	print '<table width="100%" border=0><tr><td align=center>';
	print '<form action="?" method="POST" enctype="multipart/form-data">',"\n";
	print '<input type="hidden" name="act" value="cre">',"\n";
	print '<input type="hidden" name="cname" value="',ref($o),'">',"\n";
	
	print '<input type="hidden" name="url" value="',$where->myurl(),'">',"\n";
	
	print '<table width="100%">';
	$o->admin_props();
	print '<tr><td></td><td align=right></td></tr></table>';
	
	print '<br><input type="submit" value="Добавить">';
	print '</form></td></tr></table>';
}

sub admin_view
{
	my $o = shift;
	
	$o->admin_err_print();

	
	print '<p class="hr">Данные элемента:</p>';
	print '<table width="100%" border=0><tr><td align=center>';
	print '<form action="?" ',($o->access('w')?'':'disabled'),' method="POST" enctype="multipart/form-data">',"\n";
	print '<input type="hidden" name="act" value="edit">',"\n";
	
	print '<input type="hidden" name="url" value="',$o->myurl(),'">';
	
	print '<table width="100%">';
	
	$o->admin_props();
	
	print '<tr id="hide1"><td></td><td><a onclick="ShowDetails()" href="#">Дополнительно &gt;&gt;</a></td></tr>';
	print '<tr style="DISPLAY: none" id="show1"><td valign=top>Создан:</td><td>',JDBI::fromTIMESTAMP($o->{'CTS'}),'</td></tr>';
	print '<tr style="DISPLAY: none" id="show2"><td valign=top>Изменён:</td><td>',JDBI::fromTIMESTAMP($o->{'ATS'}),'</td></tr>';
	
	my $chown = ($JDBI::group->{'root'})?'<a href="?act=chown&url='.$o->myurl().'"><u>':'';
	my $tu = User->new();
	$tu->load($o->{'OID'});
	print '<tr style="DISPLAY: none" id="show3"><td valign=top>',$chown,'Владелец</u></a>:</td><td>',$tu->name(),'</td></tr>';
	$tu->clear();
	
	my $chmod = $o->access('c')?'<a href="?act=chmod&url='.$o->myurl().'"><u>':'';
	print '<tr style="DISPLAY: none" id="show4"><td valign=top>',$chmod,'Разрешения:</u></a></td><td>',$o->access_print(),'.</td></tr>';
	print '<tr style="DISPLAY: none" id="show5"><td valign=top>HTTP адрес:</td><td>',$o->des_href(),'</td></tr>';
	
	print '<tr><td></td><td align=right></td></tr></table>';
	
	if($o->access('w')){ print '<center><br><input type="submit" value="Сохранить"></center>'; }
	
	print '</form></td></tr></table>';
}

sub admin_props
{
	my $o = shift;
	my ($key,@keys,$vtype);
	
	my $p = \%{ ref($o).'::props' };
	
	if( $#{ ref($o).'::aview' } > -1 ){ @keys = @{ ref($o).'::aview' }; }else{ @keys = keys( %$p ); }
	for $key (@keys){
		$vtype = 'JDBI::vtypes::'.$p->{$key}{'type'};
		if(${ $vtype.'::admin_own_html' }){
			print $vtype->aview( $key, $o->{$key}, $o );
		}else{
			print '<tr><td valign=top width="20%" valign="center"><label for="',$key,'">',$p->{$key}{'name'},':</td><td width="80%" align="left" valign="middle">';
			print $vtype->aview( $key, $o->{$key}, $o );
			print '</td></tr>';
		}
	}
}

sub admin_err_print
{
	my $o = shift;
	
	if($o->err_is()){
		
		print '<table align="center"><tr><td class="mes_table"><font color="red">Возникла ошибка!</font><br><br>';
		$o->err_print();
		print '</td></tr></table><br>';
	}
	
	if($o->{'_print'}){
		
		print '<table align="center"><tr><td class="mes_table">',$o->{'_print'},'</td></tr></table><br>';
		$o->{'_print'} = '';
	}
}

return 1;