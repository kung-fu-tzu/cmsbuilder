package DBObject;
use strict qw(subs vars);
my %vtypes;
my $page = '/page.ehtml';

my $admin_left_max_name_len = 20;



###################################################################################################
# Следующие методы находятся в разработке
###################################################################################################

sub url
{
	my $url = shift;
	
	my ($class,$id) = url2classid($url);
	
	my $to = &{$class.'::new'}($id);
	
	return $to;
}

sub url2classid
{
	my $url = shift;
	
	my ($class,$id) = ('','');
	
	if( $url !~ m/^([A-Za-z]+)(\d+)$/ ){ eml::err505('Invalid object requested: '.$url); }
	
	$class = $1;
	$id = $2;
	
	if( ! eml::classOK($class) ){ eml::err505('Invalid class name requested: '.$class); }
	
	return ($class,$id);
}




###################################################################################################
# Методы реализации разделения доступа
###################################################################################################

sub do_access
{
	
	
	
	
}

sub access
{
	my $o = shift;
	my $type = shift;
	
	if(length($type) != 1){ return 0; }
	
	#if( $eml::gid == 0 ){ return 1; }
	
	my $papa = $o->papa();
	
	if($papa->{'ID'} != -1){
		if( !$papa->acces($type) == 0 ){ return 0; }
	}
	
	return 0;
	
}


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
	if($o->{'ID'} < 0){ return 'Объект был удалён: '.${ref($o).'::name'}.' '.$o->{'ID'} }
	
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
# Методы выполняющие поиск объектов
###################################################################################################

sub sel_one
{
	my $o = shift;
	my $wh = shift;
	
	my $id;
	
	$o->save();
	$o->clear();
	
	my $str = $eml::dbh->prepare('SELECT ID FROM `dbo_'.ref($o).'` WHERE '.$wh);
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
	
	my $str = $eml::dbh->prepare('SELECT ID FROM `dbo_'.ref($o).'` WHERE '.$wh);
	$str->execute(@_);
	
	while( ($id) = $str->fetchrow_array() ){
		
		push(@oar,&{ref($o).'::new'}($id));
		
	}
	
	return @oar;
}

sub o_sql
{
	my $o = shift;
	my $wh = shift;
	
	my $id;
	my @oar;
	
	my $str = $eml::dbh->prepare($wh);
	$str->execute(@_);
	
	while( ($id) = $str->fetchrow_hashref('NAME_lc') ){
		
		push(@oar,&{ref($o).'::new'}($id->{'id'}));
		
	}
	
	return @oar;
}


###################################################################################################
# Методы автоматизации администрирования
###################################################################################################

sub admin_left
{
	my $o = shift;
	my $img = $o->{'_is_ref'}?'ref.gif':'dot.gif';
	
	print '<nobr><img class="icon" align="absmiddle" src="',$img,'">',$o->admin_name(),'</nobr><br>',"\n";
}

sub admin_name
{
	my $o = shift;
	my $ret;
	
	$ret = $o->name();
	
	$ret =~ s/\<(?:.|\n)+?\>//g;
	if(length($ret) > $admin_left_max_name_len){ $ret = substr($ret,0,$admin_left_max_name_len-1).'...' }
	
	if(!$ret){ $ret = ${ref($o).'::name'}.' без имени' }
	
	return '<span class="ahref" id="id_'.$o->myurl().'"> <a target="admin_right" href="right.ehtml?url='.$o->myurl().'">'.$ret.'</a> </span>';
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

sub admin_edit
{
	my $o = shift;
	my ($key,$val,@keys);
	my %p = $o->props();
	
	if($o->{'ID'} < 1){ $o->err_add('Объект не существует.'); return; }
	
	if( $#{ ref($o).'::aview' } > -1 ){ @keys = @{ ref($o).'::aview' }; }else{ @keys = keys( %p ); }
	
	for $key (@keys){
		
		$val = eml::param($key);
		
		if(!$eml::g_group->{'html'}){ $val = eml::HTMLfilter($val); }
		
		if( $DBObject::vtypes{ $p{$key}{'type'} }{'aedit'} ){
			$val = $DBObject::vtypes{ $p{$key}{'type'} }{'aedit'}->($key,$val,$o);
		}
		
		$o->{$key} = $val;
	}
	
	if($o->err_is()){ $o->{'_print'} = "Изменения частично внесены.<br>\n"; }
	else{ $o->{'_print'} = "Изменения успешно внесены.<br>\n"; }
}

sub admin_cre
{
	my $o = shift;
	my $w = shift;
	
	$o->{'_print'} = 'Создание элемента...';
	return $o->admin_view('cre',$w);
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
	print '<form action="?" method="POST" enctype="multipart/form-data">',"\n";
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
		print $DBObject::vtypes{ $p{$key}{'type'} }{'aview'}->( $key, $o->{$key}, $o );
		print '</td></tr>';
	}
	
	if($act ne 'cre'){
		print '<tr><td valign=top>Создан:</td><td>',$o->fromTIMESTAMP($o->{'CTS'}),'</td></tr>';
		print '<tr><td valign=top>Изменён:</td><td>',$o->fromTIMESTAMP($o->{'ATS'}),'</td></tr>';
		my $tu = User::new($o->{'OID'});
		print '<tr><td valign=top>Владелец:</td><td>',$tu->name(),'</td></tr>';
	}
	
	print "<tr>\n  <td>\n  </td>\n  <td align=right>\n";
	print "\n";
	print "  </td>\n</tr>\n";
	
	print "</table>\n";
	
	print '<center><br><input type=submit value=Сохранить></center>';
	
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
	
	for $key (keys( %$o )){
		
		$o->{$key} = '';
	}
	
	$o->{'ID'} = -1;
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
	
	my $str = $eml::dbh->prepare('SELECT ID FROM `dbo_'.ref($o).'` ORDER BY '.$col.$lim);
	$str->execute();
	
	while( ($id) = $str->fetchrow_array() ){
		push @ar, $id;
	}
	
	return @ar;
}

sub count
{
	my $o = shift;
	
	my $str = $eml::dbh->prepare('SELECT COUNT(ID) FROM `dbo_'.ref($o).'`');
	$str->execute();
	
	my ($res) = $str->fetchrow_array();
	
	return $res;
}

sub del
{
	my $o = shift;
	my $key;
	my %p = $o->props();
	
	if($o->{'ID'} eq 'cre'){ $o->clear(); return; }
	if($o->{'ID'} < 0){ $o->clear(); return; }
	if($o->{'ID'} =~ m/\D/){ eml::err505('DBO: Non-digital ID passed to del(), '.ref($o).', '.$o->{'ID'}); }
	
	
	for $key (keys( %p )){
		
		if( $DBObject::vtypes{ $p{$key}{'type'} }{'del'} ){
			
			$DBObject::vtypes{ $p{$key}{'type'} }{'del'}->( $key, $o->{$key}, $o );
			
		}
		
	}
	
	my $str = $eml::dbh->prepare('DELETE FROM `dbo_'.ref($o).'` WHERE ID = ? LIMIT 1');
	$str->execute($o->{'ID'});
	
	$o->clear();
}

sub reload
{
	my $o = shift;
	my $key;
	my %p = $o->props();
	
	if($o->{'ID'} eq 'cre'){ $o->{'ID'} = $o->insert(); }
	if($o->{'ID'} < 0){ return; }
	if($o->{'ID'} =~ m/\D/){ eml::err505('DBO: Non-digital ID passed to reload(), '.ref($o).", $o->{'ID'}"); }
	
	my $str = $eml::dbh->prepare('SELECT * FROM `dbo_'.ref($o).'` WHERE ID = ? LIMIT 1');
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
			if($id < 1){ $id = 'cre' }
			$o->{$key} = &{ $p{$key}{'class'}.'::new' }($id);
			$o->{$key}->{'PAPA_ID'} = $o->{'ID'};
			$o->{$key}->{'PAPA_CLASS'} = ref($o);
		}
	}
	
	$o->{'PAPA_ID'} = $res->{'papa_id'};
	$o->{'PAPA_CLASS'} = $res->{'papa_class'};
	$o->{'OID'} = $res->{'oid'};
	$o->{'CTS'} = $res->{'cts'};
	$o->{'ATS'} = $res->{'ats'};
	
	if($have_o == 1){ $o->save() }
}


sub save
{
	my $o = shift;
	my $key;
	my %p = $o->props();
	my @vals = ();
	my $val;
	
	if($o->{'ID'} eq 'cre'){ $o->{'ID'} = $o->insert(); }
	if($o->{'ID'} < 0){ return; }
	if($o->{'ID'} =~ m/\D/){ eml::err505('DBO: Non-digital ID passed to save(), '.ref($o).', '.$o->{'ID'}); }
	
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
	
	my $str = $eml::dbh->prepare($sql);
	$str->execute($o->{'OID'},$o->{'PAPA_ID'},$o->{'PAPA_CLASS'},@vals,$o->{'ID'});
}

sub insert
{
	my $o = shift;
	my $str;
	
	$str = $eml::dbh->prepare('INSERT INTO `dbo_'.ref($o).'` (OID,CTS) VALUES (?,NOW())');
	$str->execute($eml::uid);
	
	$str = $eml::dbh->prepare('SELECT LAST_INSERT_ID() FROM `dbo_'.ref($o).'` LIMIT 1');
	$str->execute();
	my $id;
	
	($id) = $str->fetchrow_array();
	
	return $id;
}


sub creTABLE
{
	my $class = shift;
	my $key;
	my %p;
	
	%p = %{$class.'::props'};
	
	print '<br><a onclick="sql_',$class,'.style.display = \'block\'; return false;" href="open">+</a> <b>Создание таблицы для класса "',$class,'":</b><br>';
	
	my $sql = 'CREATE TABLE IF NOT EXISTS `dbo_'.$class.'` ( '."\n";
	$sql .= '`ID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY , '."\n";
	$sql .= '`OID` INT DEFAULT \'-1\' NOT NULL, '."\n";
	$sql .= '`ATS` TIMESTAMP NOT NULL, '."\n";
	$sql .= '`CTS` TIMESTAMP NOT NULL, '."\n";
	$sql .= '`PAPA_ID` INT DEFAULT \'-1\' NOT NULL, '."\n";
	$sql .= '`PAPA_CLASS` VARCHAR(20) NOT NULL, '."\n";
	
	for $key (keys( %p )){
		if($DBObject::vtypes{ $p{$key}{'type'} }{'table_cre'}){
			$sql .= " `$key` ".$DBObject::vtypes{ $p{$key}{'type'} }{'table_cre'}->($p{$key}).' NOT NULL , '."\n";
		}
	}
	$sql =~ s/,\s*$//;
	$sql .= "\n )";
	
	my $str = $eml::dbh->prepare($sql);
	$str->execute();
	
	$sql =~ s/\n/<br>\n/g;
	
	print '<div style="DISPLAY: none" id="sql_',$class,'">',$sql,'</div>';
}


###################################################################################################
# Методы для реализации наследования Perl
###################################################################################################

sub DESTROY
{
	my $o = shift;
	if($o->{'_temp_object'}){ return; }
	$o->save();
}

sub props
{
	my $o = shift;
	
	return %{ref($o).'::props'};
}

sub _construct
{
	my $o = shift;
	my $n = shift;
	my $no_cache = shift;
	
	if($n eq ''){ $n = -1; }
	
	if($eml::dbo_cache{ref($o).$n}){ $o->{'ID'} = -1; return $eml::dbo_cache{ref($o).$n} };
	
	$o->{'ID'} = $n;
	$o->reload();
	
	$o->do_access();
	
	if($o->{'ID'} > -1){ $eml::dbo_cache{ref($o).$o->{'ID'}} = $o; }
	
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

sub fromTIMESTAMP
{
	my $o = shift;
	my $ts = shift;
	
	my $str = $eml::dbh->prepare('SELECT DATE_FORMAT(?,\'%d %M %Y г., %H:%i:%s\')');
	$str->execute($ts);

	my $date;
	($date) = $str->fetchrow_array();
	
	$date =~ s/^0//;
	
	$date =~ s/January/Января/i;
	$date =~ s/February/Февраля/i;
	$date =~ s/March/Марта/i;
	$date =~ s/April/Апреля/i;
	$date =~ s/May/Мая/i;
	$date =~ s/June/Июня/i;
	$date =~ s/July/Июля/i;
	$date =~ s/August/Августа/i;
	$date =~ s/September/Сентября/i;
	$date =~ s/October/Октября/i;
	$date =~ s/November/Ноября/i;
	$date =~ s/December/Декабря/i;
	
	return $date;
}

sub url
{
	my $url = shift;
	
	my ($class,$id) = url2classid($url);
	
	my $to = &{$class.'::new'}($id);
	
	return $to;
}

sub url2classid
{
	my $url = shift;
	
	my ($class,$id) = ('','');
	
	if( $url !~ m/^([A-Za-z]+)(\d+)$/ ){ eml::err505('Invalid object requested: '.$url); }
	
	$class = $1;
	$id = $2;
	
	if( ! eml::classOK($class) ){ eml::err505('Invalid class name requested: '.$class); }
	
	return ($class,$id);
}

sub no_cache
{
	my $o = shift;
	
	my $no = &{ref($o).'::new'}();
	$no->load($o->{'ID'});
	
	return $no;
}

sub myurl
{
	my $o = shift;
	
	return ref($o).$o->{'ID'};
}

sub print_props
{
	my $o = shift;
	my $key;
	my %p = $o->props();
	
	print '<table border=1>';
	
	print '<tr><td align=center colSpan=2><b>'.ref($o).'</b></td></tr>';
	
	for $key (keys( %p )){
		print '<tr><td>',$p{$key}{'name'},' (',$key,'):</td><td><b>',$p{$key}{'type'},'</b></td></tr>';
	}
	
	print '</table>';
	
	return '';
}

sub purge_cache { %eml::dbo_cache = (); }

sub dump_cache
{
	my $obj;
	for $obj (keys(%eml::dbo_cache)){ print $eml::dbo_cache{$obj}->name(),'<br>'; }
}

sub papa
{
	my $o = shift;
	
	if($o->{'PAPA_CLASS'} eq '' or $o->{'PAPA_ID'} < 0){ return undef; }
	
	return &{ $o->{'PAPA_CLASS'}.'::new' }($o->{'PAPA_ID'});
}


###################################################################################################
# Включение виртуальных типов
###################################################################################################

my $f;
if(!opendir(DBOVTYPES,$eml::jlib.'/vtypes')){err505('Can`t open vtypes directory: '.$eml::jlib.'/vtypes');}
while($f = readdir(DBOVTYPES)){
	if(! -f "$eml::jlib/vtypes/$f"){next;}
	require "$eml::jlib/vtypes/$f";
}
closedir(DBOVTYPES);

return 1;

