package JDBI::Object;
use strict qw(subs vars);
my %vtypes;
my $page = '/page.ehtml';

my $admin_left_max_name_len = 20;



###################################################################################################
# Следующие методы находятся в разработке
###################################################################################################



###################################################################################################
# Методы вывода данных в дизайн
###################################################################################################

sub des_tree
{
	my $o = shift;
	
	my @all;
	my $count = 0;
	
	unshift(@all,$o->name());
	
	while($o = $o->papa() and $count < 50){
		$count++;
		unshift(@all, $o->des_name());
	}
	
	print join(' :: ',@all);
}

sub des_page
{
	my $o = shift;
	
	print '<b>',$o->{'name'},'</b> Страничный вывод для класса "',ref($o),'" не определён!';
}

sub des_title
{
	my $o = shift;
	return $o->name();
}

sub des_preview
{
	my $o = shift;
	
	print '<b>',$o->{'name'},'</b> Предварительный вывод для класса "',ref($o),'" не определён!';
}

sub des_href
{
	my $o = shift;
	my $page = shift;
	
	return ${ref($o).'::page'}.'?obj='.$o->myurl();
}

sub des_name
{
	my $o = shift;
	
	my $dname = $o->{'name'};
	if(!$dname){ $dname = ${ref($o).'::name'}; }
	
	return '<a href="'.$o->des_href().'">'.$dname.'</a>';
}

sub name
{
	my $o = shift;
	my $ret;
	
	if($o->{'name'}){ return $o->{'name'} }
	if($o->{'ID'} < 1){ return 'Объект был удалён: '.${ref($o).'::name'}.' '.$o->{'ID'} }
	
	return ${ref($o).'::name'}.' '.$o->{'ID'};
}

sub file_href
{
	my $o = shift;
	my $name = shift;
	my $id = $o->{'ID'};
	my %props = $o->props();
	
	return '/files/'.$o->myurl().'_'.$name.'.'.$o->{$name};
}


###################################################################################################
# Методы автоматизации администрирования
###################################################################################################

sub admin_left
{
	my $o = shift;
	
	if($o->{'_is_shcut'}){
		print '<nobr><img class="icon" align="absmiddle" src="shcut.gif">',$o->admin_name(),'</nobr><br>',"\n";
	}else{
		print '<nobr><img class="icon" align="absmiddle" src="dot.gif">',$o->admin_name(),'</nobr><br>',"\n";
	}
}

sub admin_name
{
	my $o = shift;
	my $ret;
	
	$ret = $o->name();
	
	$ret =~ s/\<(?:.|\n)+?\>//g;
	if(length($ret) > $admin_left_max_name_len){ $ret = substr($ret,0,$admin_left_max_name_len-1).'...' }
	
	if(!$ret){ $ret = ${ref($o).'::name'}.' без имени' }
	
	if(!$o->access('r')){ return '<span style="CURSOR: default" class="ahref" id="id_'.$o->myurl().'"> '.$ret.' </span>'; }
	
	if($o->{'_is_shcut'}){
		return '<span class="ahref"> <a target="admin_right" href="right.ehtml?url='.$o->myurl().'">'.$ret.'</a> </span>';
	}else{
		return '<span class="ahref" id="id_'.$o->myurl().'"> <a target="admin_right" href="right.ehtml?url='.$o->myurl().'">'.$ret.'</a> </span>';
	}
}

sub admin_tree
{
	my $o = shift;
	my $me = $o;
	
	my @all;
	my $count = 0;
	
	print '<script>',"\n";
	
	do{
		$count++;
		unshift(@all, $o->admin_name());
		
		print 'ShowMe(parent.frames.admin_left.document.all["dbi_'.ref($o).$o->{'ID'}.'"],parent.frames.admin_left.document.all["dbdot_'.ref($o).$o->{'ID'}.'"]); ',"\n";
		
	}while( $o = $o->papa() and $count < 50 );
	
	print 'SelectLeft(parent.frames.admin_left.document.all["id_'.ref($me).$me->{'ID'}.'"]);',"\n";
	
	print '</script>';
	
	print join(' :: ',@all);
}

sub admin_cre
{
	my $o = shift;
	my $w = shift;
	
	$o->{'_print'} = 'Создание элемента...';
	return $o->admin_view('cre',$w);
}

sub admin_edit
{
	my $o = shift;
	my ($key,$val,@keys);
	my %p = $o->props();
	
	if($o->{'ID'} < 1){ $o->err_add('Объект не существует.'); return; }
	
	if( $#{ ref($o).'::aview' } > -1 ){ @keys = @{ ref($o).'::aview' }; }else{ @keys = keys( %p ); }
	
	for $key (@keys){
		
		$val = CGI::param($key);
		
		if(!$JDBI::g_group->{'html'}){ $val = JDBI::HTMLfilter($val); }
		
		if( $DBObject::vtypes{ $p{$key}{'type'} }{'aedit'} ){
			$val = $DBObject::vtypes{ $p{$key}{'type'} }{'aedit'}->($key,$val,$o);
		}
		
		$o->{$key} = $val;
	}
	
	if($o->err_is()){ $o->{'_print'} = "Изменения частично внесены.<br>\n"; }
	else{ $o->{'_print'} = "Изменения успешно внесены.<br>\n"; }
}

sub admin_view
{
	my $o = shift;
	my $act = shift;
	my $key;
	my @keys;
	my %p = $o->props();
	
	if(!$act){ $act = 'edit' }
	
	
	if($o->err_is()){
		
		print '<table align="center"><tr><td class="mes_table"><font color="red">Возникла ошибка!</font><br><br>';
		$o->err_print();
		print '</td></tr></table><br>';
	}
	
	if($o->{'_print'}){
		
		print '<table align="center"><tr><td class="mes_table">',$o->{'_print'},'</td></tr></table><br>';
		$o->{'_print'} = '';
	}

	print '<table width="100%" border=0><tr><td align=center>';
	print '<form action="?" ',(($o->access('w') or $act eq 'cre')?'':'disabled'),' method="POST" enctype="multipart/form-data">',"\n";
	print '<input type="hidden" name="act" value="',$act,'">',"\n";
	
	if($act eq 'edit'){ print '<input type="hidden" name="url" value="',$o->myurl(),'">',"\n"; }
	if($act eq 'cre'){
		my $where = shift;
		print '<input type="hidden" name="cname" value="',ref($o),'">',"\n";
		print '<input type="hidden" name="url" value="',$where->myurl(),'">',"\n";
	}
	
	print '<table width="100%">',"\n";
	
	if( $#{ ref($o).'::aview' } > -1 ){ @keys = @{ ref($o).'::aview' }; }else{ @keys = keys( %p ); }
	for $key (@keys){
		
		print '<tr><td valign=top width="100">'.$p{$key}{'name'}.':</td><td>';
		print $JDBI::vtypes{ $p{$key}{'type'} }{'aview'}->( $key, $o->{$key}, $o );
		print '</td></tr>';
	}
	
	if($act ne 'cre'){
		print '<tr id="hide1"><td></td><td><a onclick="ShowDetails()" href="#">Дополнительно &gt;&gt;</a></td></tr>';
		print '<tr style="DISPLAY: none" id="show1"><td valign=top>Создан:</td><td>',JDBI::fromTIMESTAMP($o->{'CTS'}),'</td></tr>';
		print '<tr style="DISPLAY: none" id="show2"><td valign=top>Изменён:</td><td>',JDBI::fromTIMESTAMP($o->{'ATS'}),'</td></tr>';
		
		my $chown = $JDBI::g_group->{'root'}?'<a href="?act=chown&url='.$o->myurl().'"><u>':'';
		my $tu = User->new();
		$tu->load($o->{'OID'});
		print '<tr style="DISPLAY: none" id="show3"><td valign=top>',$chown,'Владелец</u></a>:</td><td>',$tu->name(),'</td></tr>';
		$tu->clear();
		
		my $chmod = $o->access('c')?'<a href="?act=chmod&url='.$o->myurl().'"><u>':'';
		print '<tr style="DISPLAY: none" id="show4"><td valign=top>',$chmod,'Разрешения:</u></a></td><td>',$o->access_print(),'.</td></tr>';
	}
	
	print "<tr>\n  <td>\n  </td>\n  <td align=right>\n";
	print "\n";
	print "  </td>\n</tr>\n";
	
	print "</table>\n";
	
	if($o->access('w') or $act eq 'cre'){ print '<center><br><input type=submit value=Сохранить></center>'; }
	
	print "</form>\n\n";
	print "  </td>\n</tr>\n</table>";
}


###################################################################################################
# Вспомогательные методы работы с Базой Данных
###################################################################################################

sub save_as
{
	my $o = shift;
	my $n = shift;
	
	$o->{'ID'} = $n;
	$o->save();
	
	return $n;
}

sub save_to
{
	my $o = shift;
	my $n = shift;
	my $t = 0;
	
	$t = $o->{'ID'};
	$o->{'ID'} = $n;
	$o->save();
	$o->{'ID'} = $t;
	
	return $n;
}

sub loadr
{
	my $o = shift;
	my $n = shift;
	
	$o->clear();
	
	$o->{'ID'} = $n;
	$o->reload();
}

sub load
{
	my $o = shift;
	my $n = shift;
	
	$o->save();
	$o->clear();
	
	$o->{'ID'} = $n;
	$o->reload();
}

sub clear
{
	my $o = shift;
	my $key;
	
	for $key (keys( %$o )){ $o->{$key} = ''; }
	
	$o->{'ID'} = 0;
}

sub clear_data
{
	my $o = shift;
	my $key;
	my %p = $o->props();
	
	for $key (keys( %p )){
		
		$o->{$key} = '';
	}
}


###################################################################################################
# Методы для непосредственной работы с Базой Данных
###################################################################################################

sub IDs
{
	my $o = shift;
	my $col = shift;
	my $lim = shift;
	my $id = 0;
	my @ar;
	
	if(!$col){ $col = 'ID' }
	if($lim){ $lim = ' LIMIT '.$lim }
	
	my $str = $JDBI::dbh->prepare('SELECT ID FROM `dbo_'.ref($o).'` ORDER BY '.$col.$lim);
	$str->execute();
	
	while( ($id) = $str->fetchrow_array() ){
		push @ar, $id;
	}
	
	return @ar;
}

sub count
{
	my $o = shift;
	
	my $str = $JDBI::dbh->prepare('SELECT COUNT(ID) FROM `dbo_'.ref($o).'`');
	$str->execute();
	
	my ($res) = $str->fetchrow_array();
	
	return $res;
}

sub del
{
	my $o = shift;
	my $key;
	my %p = $o->props();
	
	if($o->{'_temp_object'}){ $o->clear(); return; }
	if($o->{'ID'} < 1){ $o->clear(); return; }
	if($o->{'ID'} =~ m/\D/){ JDBI::err505('DBO: Non-digital ID passed to del(), '.ref($o).', '.$o->{'ID'}); }
	
	my $papa = $o->papa();
	if(!$papa){
		if(!$o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
	}else{
		if(!$papa->access('x')){ $o->err_add('У Вас нет разрешения изменять родителя этого элемента.'); return; }
	}
	
	for $key (keys( %p )){
		
		if( $DBObject::vtypes{ $p{$key}{'type'} }{'del'} ){
			
			$DBObject::vtypes{ $p{$key}{'type'} }{'del'}->( $key, $o->{$key}, $o );
			
		}
		
	}
	
	my $str = $JDBI::dbh->prepare('DELETE FROM `dbo_'.ref($o).'` WHERE ID = ? LIMIT 1');
	$str->execute($o->{'ID'});
	
	$o->clear();
}

sub reload
{
	my $o = shift;
	my $key;
	my %p = $o->props();
	
	if($o->{'ID'} < 1){ return; }
	if($o->{'ID'} =~ m/\D/){ JDBI::err505('DBO: Non-digital ID passed to reload(), '.ref($o).", $o->{'ID'}"); }
	
	my $str = $JDBI::dbh->prepare('SELECT * FROM `dbo_'.ref($o).'` WHERE ID = ? LIMIT 1');
	$str->execute($o->{'ID'});
	
	my $res = $str->fetchrow_hashref('NAME_lc');
	
	if($res->{'id'} != $o->{'ID'}){ print STDERR 'DBO: Loading from not existed row, class = "'.ref($o).'",ID = '.$o->{'ID'}."\n"; $o->clear(); return; }
	
	my $id = 0;
	my $have_o = 0;
	
	for $key (keys( %p )){
		$o->{$key} = $res->{$key};
		
		if( $p{$key}{'type'} eq 'object' ){
			
			$have_o = 1;
			
			$id = $o->{$key};
			if($id < 1){ $o->{$key} = $p{$key}{'class'}->cre(); }
			else{ $o->{$key} = $p{$key}{'class'}->new($id); }
			$o->{$key}->{'PAPA_ID'} = $o->{'ID'};
			$o->{$key}->{'PAPA_CLASS'} = ref($o);
		}
	}
	
	$o->{'PAPA_ID'} = $res->{'papa_id'};
	$o->{'PAPA_CLASS'} = $res->{'papa_class'};
	$o->{'OID'} = $res->{'oid'};
	$o->{'CTS'} = $res->{'cts'};
	$o->{'ATS'} = $res->{'ats'};
	
	
	if(!$o->access('r')){
		
		#my $t_papaid = $o->{'PAPA_ID'};
		#my $t_papac = $o->{'PAPA_CLASS'};
		#my $t_id = $o->{'ID'};
		#my $t_oid = $o->{'OID'};
		my $t_name = $o->name();
		$o->clear_data();
		#$o->{'ID'} = $t_id;
		#$o->{'OID'} = $t_oid;
		$o->{'name'} = $t_name; #'Чтение не разрешено';
		#$o->{'PAPA_ID'} = $t_papaid;
		#$o->{'PAPA_CLASS'} = $t_papac;
		
	}
	
	if($have_o == 1){ $o->save() }
}


sub save
{
	my $o = shift;
	my $key;
	my %p = $o->props();
	my @vals = ();
	my $val;
	
	if($o->{'_temp_object'}){ return; }
	if($o->{'ID'} < 1){ return; }
	if(!$o->access('w')){ return; }
	if($o->{'ID'} =~ m/\D/){ JDBI::err505('DBO: Non-digital ID passed to save(), '.ref($o).', '.$o->{'ID'}); }
	
	#print 'Saving: ',$o->myurl(),'<br>';
	
	my $sql = 'UPDATE `dbo_'.ref($o).'` SET ';
	$sql .= ' OID = ?, PAPA_ID = ?, PAPA_CLASS = ?, ';
	
	for $key (keys( %p )){
		$sql .= "\n $key = ?,";
		
		if( $p{$key}{'type'} eq 'object' ){
			
			if($o->{$key}){
				$o->{$key}->save();
				$val = $o->{$key}->{'ID'};
			}else{
				$val = -1;
			}
		}
		else{ $val = $o->{$key}; }
		
		push @vals, $val;
		
	}
	
	chop($sql);
	
	$sql .=  "\n".' WHERE ID = ? LIMIT 1';
	
	my $str = $JDBI::dbh->prepare($sql);
	$str->execute($o->{'OID'},$o->{'PAPA_ID'},$o->{'PAPA_CLASS'},@vals,$o->{'ID'});
}

sub insert
{
	my $o = shift;
	my $str;
	
	$str = $JDBI::dbh->prepare('INSERT INTO `dbo_'.ref($o).'` (OID,CTS) VALUES (?,NOW())');
	$str->execute(JDBI::user()->{'ID'});
	
	$str = $JDBI::dbh->prepare('SELECT LAST_INSERT_ID() FROM `dbo_'.ref($o).'` LIMIT 1');
	$str->execute();
	my $id;
	
	($id) = $str->fetchrow_array();
	
	return $id;
}


###################################################################################################
# Методы выполняющие поиск объектов
###################################################################################################

sub sel_one
{
	my $o = shift;
	my $wh = shift;
	
	my $id;
	
	$o->save();
	$o->clear();
	
	my $str = $JDBI::dbh->prepare('SELECT ID FROM `dbo_'.ref($o).'` WHERE '.$wh);
	$str->execute(@_);
	
	($id) = $str->fetchrow_array();
	
	if(! $id){ $o->clear(); return; }
	
	$o->{'ID'} = $id;
	$o->reload();
}

sub sel_where
{
	my $o = shift;
	my $wh = shift;
	
	my $id;
	my @oar;
	
	my $str = $JDBI::dbh->prepare('SELECT ID FROM `dbo_'.ref($o).'` WHERE '.$wh);
	$str->execute(@_);
	
	while( ($id) = $str->fetchrow_array() ){
		
		push(@oar,&{ref($o).'::new'}($id));
		
	}
	
	return @oar;
}

sub sel_sql
{
	my $o = shift;
	my $wh = shift;
	
	my $id;
	my @oar;
	
	my $str = $JDBI::dbh->prepare($wh);
	$str->execute(@_);
	
	while( ($id) = $str->fetchrow_hashref('NAME_lc') ){
		
		push(@oar,&{ref($o).'::new'}($id->{'id'}));
		
	}
	
	return @oar;
}


###################################################################################################
# Методы для реализации наследования Perl
###################################################################################################

sub DESTROY
{
	my $o = shift;
	$o->save();
}

sub props
{
	my $o = shift;
	
	return %{ref($o).'::props'};
}

sub new
{
	my $class = shift;
	
	my $o = {};
	bless($o,$class);
	
	return $o->_init(@_);
}

sub cre
{
	my $class = shift;
	
	my $o = {};
	bless($o,$class);
	
	$o->{'ID'} = $o->insert();
	$o->access_set('rw');
	$o->reload();
	
	return $o;
}

sub _init
{
	my $o = shift;
	my $n = shift;
	my $no_cache = shift;
	
	if(!$n){ return $o; }
	
	if($JDBI::dbo_cache{ref($o).$n}){ $o->{'ID'} = 0; return $JDBI::dbo_cache{ref($o).$n} };
	if($n > 0){ $JDBI::dbo_cache{ref($o).$n} = $o; }
	
	$o->{'ID'} = $n;
	$o->reload();
	
	if($o->{'ID'} > 0){ $JDBI::dbo_cache{ref($o).$o->{'ID'}} = $o; }
	
	return $o;
}


###################################################################################################
# Методы контроля ошибок
###################################################################################################

sub err_add
{
	my $o = shift;
	my $errstr = shift;
	
	if(!$o->{'_errors'}){ $o->{'_errors'} = (); }
	
	push(@{ $o->{'_errors'} }, $errstr);
}

sub err_print
{
	my $o = shift;
	my $errstr;
	
	for $errstr ( @{ $o->{'_errors'} } ){
		
		print $errstr,'<br>';
		
	}
	
}

sub err_is
{
	my $o = shift;
	
	return ($#{ $o->{'_errors'} } < 0) ? 0 : 1;
}


###################################################################################################
# Дополнительные методы
###################################################################################################

sub type { return 'DBObject'; }

sub no_cache
{
	my $o = shift;
	
	my $no = ref($o)->new();
	$no->load($o->{'ID'});
	$no->{'_temp_object'} = 1;
	
	return $no;
}

sub myurl
{
	my $o = shift;
	
	return ref($o).$o->{'ID'};
}

sub purge_cache { %JDBI::dbo_cache = (); }

sub dump_cache
{
	my $obj;
	for $obj (keys(%JDBI::dbo_cache)){ print $JDBI::dbo_cache{$obj}->name(),'<br>'; }
}

sub papa
{
	my $o = shift;
	
	if($o->{'PAPA_CLASS'} eq '' or $o->{'PAPA_ID'} < 1){ return undef; }
	
	return &{ $o->{'PAPA_CLASS'}.'::new' }($o->{'PAPA_ID'});
}


###################################################################################################
# Методы реализации разделения доступа
###################################################################################################

require 'JDBI/access.cgi';

return 1;

