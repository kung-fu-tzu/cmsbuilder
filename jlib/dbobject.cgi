package DBObject;
use strict qw(subs vars);
my %vtypes;
my $page = '/page.ehtml';


###################################################################################################
# Следующие методы находятся в разработке
###################################################################################################

sub url
{
	my $url = shift;
	
	my ($class,$id) = ('','');

	if( $url !~ m/^(\w+)(\d+)$/ ){ eml::err505('Invalid object requested: '.$url); }

	$class = $1;
	$id = $2;

	if( ! eml::classOK($class) ){ eml::err505('Invalid class name requested: '.$class); }

	my $to = &{$class.'::new'}($id);
	
	return $to;
}

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


###################################################################################################
# Методы вывода данных в дизайн
###################################################################################################

sub des_page
{
	my $o = shift;
	
	print '<b>',$o->{'name'},'</b> Страничный вывод для класса "',ref($o),'" не определён!';
}

sub des_name
{
	my $o = shift;
	
	my $dname = $o->{name};
	if(!$dname){ $dname = ${ref($o).'::name'}; }
	
	return '<a href="'.${ref($o).'::page'}.'?obj='.ref($o).$o->{'ID'}.'">'.$dname.'</a>';
}

sub name
{
	my $o = shift;
	my $ret;
	
	if($o->{name}){ return $o->{name} }
	
	return 'Без имени ( '.${ref($o).'::name'}.' '.$o->{ID}.' )';
}

sub file_href
{
	my $o = shift;
	my $name = shift;
	my $id = $o->{ID};
	my %props = $o->props();
	
	return '/files/'.ref($o)."_${name}_$id".$props{$name}{ext};
}

sub anyfile_href
{
	my $o = shift;
	my $name = shift;
	my $id = $o->{ID};
	my %props = $o->props();
	
	return '/files/'.ref($o)."_${name}_$id".$o->{$name};
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
	
	if(! $id){ return; }
	
	$o->{ID} = $id;
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
	
	print '<nobr><img class="icon" align="absmiddle" src="dot.gif">',$o->admin_name(),'</nobr><br>',"\n";
}

sub admin_name
{
	my $o = shift;
	my $ret;
	
	if($o->{name}){
		$ret = $o->{name};
	}else{
		$ret = 'Без имени ( '.${ref($o).'::name'}.' '.$o->{ID}.' )';
	}
	
	#$ret =~ s/\s/\&nbsp;/g;
	return '<a id="id_'.ref($o).$o->{'ID'}.'" target="admin_right" href="right.ehtml?class='.ref($o).'&ID='.$o->{'ID'}.'">'.$ret.'</a>';
}

sub admin_tree
{
	my $o = shift;
	my $me = $o;
	
	my @all;
	my $count = 0;
	
	print '<script>';
	
	do{
		$count++;
		unshift(@all, '<a target="admin_right" href=right.ehtml?class='.ref($o).'&ID='.$o->{ID}.'>'.$o->name().'</a>');
		
		print 'ShowMe(parent.frames.admin_left.document.all.dbi_'.ref($o).$o->{'ID'}.',parent.frames.admin_left.document.all.dbdot_'.ref($o).$o->{'ID'}.'); ';
		
	}while( $o = $o->papa() and $count < 50 );
	
	print 'SelectLeft(parent.frames.admin_left.document.all.id_'.ref($me).$me->{'ID'}.');';
	
	print '</script>';
	
	print join(' :: ',@all);
}

sub admin_list
{
	my $o = shift;
	my $col = shift;
	my $page = shift;
	my $i;
	
	my $onp = 20;
	
	$page =~ s/\D//g;
	
	my $pages = $o->count();
	
	$pages /= $onp;
	$pages = ( $pages == int($pages) )?$pages:( int($pages) + 1);
	
	if($page < 0 or $page eq ''){ $page = 0; }
	if($page >= $pages){ $page = $pages - 1; }
	
	$col =~ s/\W//g;
	
	my $lim = ($page * $onp) . ',' . $onp;
	
	print '<table border=0 cellspacing=0 cellpadding=0>';
	
	for $i ( $o->IDs($col,$lim) ){
		
		$o->loadr($i);
		
		print '<tr><td height=15>';
		
		if($o->{PAPA_ID} < 0){ print "<a style='CURSOR: default' onclick='return doDel()' href=?class=".ref($o)."&ID=$i&act=del><img onmouseover=\"this.src='x_on.gif'\" onmouseout=\"this.src='x.gif'\" border=0 src=x.gif></a>"; }
		else{ print "<img border=0 src=nx.gif>" }
		
		print '</td><td width=10></td><td valign=top>';
		
		print "<a href=?class=".ref($o)."&ID=$i>".$o->name()."</a>";
		
		print '</td></tr>';
	}
	
	print '</table><br><center>';
	
	for(my $p=0;$p<$pages;$p++){
		
		if($p == $page){ print ' <b>'.($p+1).'</b> '; }
		else{ print ' <a href="?class='.ref($o).'&page='.$p.'">'.($p+1).'</a> '; }
	}
	
	print '</center>';
}

sub admin_edit
{
	my $o = shift;
	my ($key,$val);
	my %p = $o->props();
	if($eml::gid != 0){ eml::err403("DBO: EDIT with gid != 0,".ref($o).", ".$o->{ID}); }
	
	if($o->{ID} < 1){ $o->{'_print'} = "<font color=red>Ошибка: ID < 1.</font><br>\n"; return; }
	
	for $key (keys( %p )){
		
		$val = eml::param($key);
		
		if( $DBObject::vtypes{ $p{$key}{type} }{aedit} ){
			$val = $DBObject::vtypes{ $p{$key}{type} }{aedit}->($key,$val,$o);
		}
		
		$o->{$key} = $val;
	}
	
	$o->{'_print'} = "Успешно сохранено.<br>\n";
}

sub admin_view
{
	my $o = shift;
	my $key;
	my @keys;
	my %p = $o->props();
	if($eml::gid != 0){ eml::err403("DBO: VIEW with gid != 0,".ref($o).", ".$o->{ID}); }
	
	print "\n\n";
	print '<table width="100%" border=0><tr><td align=center>';
	print "<!-- VIEW '".ref($o)."' WHERE ID = $o->{ID} -->\n";
	if($o->{'_print'}){ print $o->{'_print'}; $o->{'_print'} = ''; }
	print '<form action="?" method="POST" enctype="multipart/form-data">',"\n";
	print '<input type="hidden" name="ID" value="',$o->{ID},'">',"\n";
	print '<input type="hidden" name="act" value="edit">',"\n";
	print '<input type="hidden" name="class" value="'.ref($o).'">',"\n";
	
	print '<table width="100%">',"\n";
	
	if( $#{ ref($o).'::aview' } > -1 ){ @keys = @{ ref($o).'::aview' }; }else{ @keys = keys( %p ); }
	for $key (@keys){
		
		print "<tr><td valign=top><b>".$p{$key}{name}.":</b></td><td>\n";
		print $DBObject::vtypes{ $p{$key}{type} }{aview}->( $key, $o->{$key}, $o );
		print "\n</td>\n</tr>\n";
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
	
	#$o->{ID} = $o->saveTo($n);
	$o->{'ID'} = $n;
	$o->save();
	
	return $n;
}

sub save_to
{
	my $o = shift;
	my $n = shift;
	my $t = 0;
	
	$t = $o->{ID};
	$o->{ID} = $n;
	$o->save();
	$o->{ID} = $t;
	
	return $n;
}

sub loadr
{
	my $o = shift;
	my $n = shift;
	
	$o->clear();
	
	$o->{ID} = $n;
	$o->reload();
}

sub load
{
	my $o = shift;
	my $n = shift;
	
	$o->save();
	$o->clear();
	
	$o->{ID} = $n;
	$o->reload();
}

sub clear
{
	my $o = shift;
	my $key;
	
	for $key (keys( %$o )){
		
		$o->{$key} = '';
	}
	
	$o->{ID} = -1;
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
	
	if($o->{ID} eq 'cre'){ $o->clear(); return; }
	if($o->{ID} < 0){ $o->clear(); return; }
	if($o->{ID} =~ m/\D/){ eml::err505('DBO: Non-digital ID passed to del(), '.ref($o).', '.$o->{ID}); }
	
	
	for $key (keys( %p )){
		
		if( $DBObject::vtypes{ $p{$key}{type} }{del} ){
			
			$DBObject::vtypes{ $p{$key}{type} }{del}->( $key, $o->{$key}, $o );
			
		}
		
	}
	
	my $str = $eml::dbh->prepare('DELETE FROM `dbo_'.ref($o).'` WHERE ID = ? LIMIT 1');
	$str->execute($o->{ID});
	
	$o->clear();
}

sub reload
{
	my $o = shift;
	my $key;
	my %p = $o->props();
	
	if($o->{ID} eq 'cre'){ $o->{ID} = $o->insert(); }
	if($o->{ID} < 0){ return; }
	if($o->{ID} =~ m/\D/){ eml::err505('DBO: Non-digital ID passed to reload(), '.ref($o).", $o->{ID}"); }
	
	my $sql = 'SELECT * FROM `dbo_'.ref($o).'` WHERE ID = ? LIMIT 1';
	
	my $str = $eml::dbh->prepare($sql);
	$str->execute($o->{ID});
	
	my $res = $str->fetchrow_hashref('NAME_lc');
	
	if($res->{id} != $o->{ID}){ eml::err505('DBO: Loading from not existed row, class = "'.ref($o).'",ID = '.$o->{ID}); }
	
	my $id = 0;
	my $have_o = 0;
	
	for $key (keys( %p )){
		$o->{$key} = $res->{$key};
		
		if( $p{$key}{type} eq 'object' ){
			
			$have_o = 1;
			
			$id = $o->{$key};
			if($id < 1){ $id = 'cre' }
			$o->{$key} = &{ $p{$key}{class}.'::new' }($id);
			$o->{$key}->{PAPA_ID} = $o->{ID};
			$o->{$key}->{PAPA_CLASS} = ref($o);
		}
	}
	
	$o->{'PAPA_ID'} = $res->{'papa_id'};
	$o->{'PAPA_CLASS'} = $res->{'papa_class'};
	$o->{'OID'} = $res->{'oid'};
	
	if($have_o == 1){ $o->save() }
}


sub save
{
	my $o = shift;
	my $key;
	my %p = $o->props();
	my @vals = ();
	my $val;
	
	if($o->{ID} eq 'cre'){ $o->{ID} = $o->insert(); }
	if($o->{ID} < 0){ return; }
	if($o->{ID} =~ m/\D/){ eml::err505('DBO: Non-digital ID passed to save(), '.ref($o).", $o->{ID}"); }
	
	my $sql = 'UPDATE `dbo_'.ref($o).'` SET ';
	$sql .= ' OID = ?, PAPA_ID = ?, PAPA_CLASS = ?, ';
	
	for $key (keys( %p )){
		$sql .= "\n $key = ?,";
		
		if( $p{$key}{type} eq 'object' ){
			
			if($o->{$key}){
				$o->{$key}->save();
				$val = $o->{$key}->{ID};
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
	$str->execute($o->{OID},$o->{PAPA_ID},$o->{PAPA_CLASS},@vals,$o->{ID});
}

sub insert
{
	my $o = shift;
	my $str;
	
	$str = $eml::dbh->prepare('INSERT INTO `dbo_'.ref($o).'` (OID) VALUES (?)');
	$str->execute($eml::uid);
	
	$str = $eml::dbh->prepare('SELECT LAST_INSERT_ID() FROM `dbo_'.ref($o).'` LIMIT 1');
	$str->execute();
	my $id;
	
	($id) = $str->fetchrow_array();
	
	return $id;
}


sub creTABLE
{
	my $o = shift;
	my $key;
	my %p;
	
	if(ref($o)){ %p = $o->props(); }
	else{ %p = &{$o.'::props'} }
	
	print '<br><a onclick="sql_',ref($o),'.style.display = \'block\'; return false;" href="open">+</a> <b>Создание таблицы для класса "',ref($o)?ref($o):$o,'":</b><br>';
	
	my $sql = 'CREATE TABLE IF NOT EXISTS `dbo_'.ref($o).'` ( '."\n";
	$sql .= '`ID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY , '."\n";
	$sql .= '`OID` INT DEFAULT \'-1\' NOT NULL, '."\n";
	$sql .= '`PAPA_ID` INT DEFAULT \'-1\' NOT NULL, '."\n";
	$sql .= '`PAPA_CLASS` VARCHAR(20) NOT NULL, '."\n";
	
	for $key (keys( %p )){
		if($DBObject::vtypes{ $p{$key}{type} }{table_cre}){
			$sql .= " `$key` ".$DBObject::vtypes{ $p{$key}{type} }{table_cre}->($p{$key}).' NOT NULL , '."\n";
		}
	}
	$sql =~ s/,\s*$//;
	$sql .= "\n )";
	
	my $str = $eml::dbh->prepare($sql);
	$str->execute();
	
	$sql =~ s/\n/<br>\n/g;
	
	print '<div style="DISPLAY: none" id="sql_',ref($o),'">',$sql,'</div>';
}


###################################################################################################
# Методы для реализации наследования Perl
###################################################################################################

sub DESTROY
{
	my $o = shift;
	$o->save();
}

sub _construct
{
	my $o = shift;
	my $n = shift;
	
	if($n eq ''){ $n = -1; }
	
	$o->{ID} = $n;
	$o->reload();
}


###################################################################################################
# Дополнительные методы
###################################################################################################

sub type { return 'DBObject'; }

sub print_props
{
	my $o = shift;
	my $key;
	my %p = $o->props();
	
	print '<table border=1>';
	
	print '<tr><td align=center colSpan=2><b>'.ref($o).'</b></td></tr>';
	
	for $key (keys( %p )){
		print '<tr><td>',$p{$key}{name},' (',$key,'):</td><td><b>',$p{$key}{type},'</b></td></tr>';
	}
	
	print '</table>';
	
	return '';
}

sub access
{
	my $o = shift;
	my $type = shift;
	
	if(length($type) != 1){ return 0; }
	
	if( $eml::gid == 0 ){ return 1; }
	
	my $papa = $o->papa();
	
	if($papa->{'ID'} != -1){
		if( !$papa->acces($type) == 0 ){ return 0; }
	}
	
	return 0;
	
}

sub papa
{
	my $o = shift;
	
	if($o->{PAPA_CLASS} eq '' or $o->{PAPA_ID} < 0){ return undef; }
	
	return &{ $o->{PAPA_CLASS}.'::new' }($o->{PAPA_ID});
}


require $eml::jlib.'/dbo_vtypes.cgi';

return 1;


