package DBObject;
use strict qw(subs vars);
#use vars '$jlib';
my %vtypes;

sub _construct
{
	my $o = shift;
	my $n = shift;

	if($n eq 'cre'){ $n = $o->insert(); }

	if($n > 0){ $o->{ID} = $n; }
	else{ $o->{ID} = -1; return; }

	$o->{DESTROYING} = 0;

	$o->reload();

}

sub IDs
{
	my $o = shift;
	my $col = shift;
	my $id = 0;
	my @ar;

	if(!$col){ $col = 'ID' }

	my $str = $main::dbh->prepare('SELECT ID FROM `dbo_'.ref($o).'` ORDER BY '.$col);
	$str->execute();

	while( ($id) = $str->fetchrow_array() ){
		push @ar, $id;
	}

	return @ar;
}

sub list
{
	my $o = shift;
	my $col = shift;
	my $i;
	
	$col =~ s/\W//g;

	print '<table border=0 cellspacing=0 cellpadding=0>';

	for $i ( $o->IDs($col) ){

		$o->loadr($i);
		
		print '<tr><td height=15>';
		
		if($o->{PAPA_ID} < 0){ print "<a style='CURSOR: default' onclick='return doDel()' href=?ID=$i&act=del><img onmouseover=\"this.src='x_on.gif'\" onmouseout=\"this.src='x.gif'\" border=0 src=x.gif></a>"; }
		else{ print "<img border=0 src=nx.gif>" }
		
		print '</td><td width=10></td><td valign=top>';
		
		print "<a href=?ID=$i>".$o->name()."</a>";
		
		print '</td></tr>';
	}

	print '</table>';

}


sub name {
	my $o = shift;

	if($o->{name}){ return $o->{name};}

	return 'Без имени ( '.${'main::'.ref($o).'::name'}.' '.$o->{ID}.' )';
}

sub aedit
{
	my $o = shift;
	my ($key,$val);
	my %p = $o->props();
	if($main::gid != 0){ main::err403("DBO: EDIT with gid != 0,".ref($o).", ".$o->{ID}); }

	if($o->{ID} < 1){ $o->{'_print'} = "<font color=red>Ошибка: ID < 1.</font><br>\n"; return; }

	for $key (keys( %p )){

		$val = main::param($key);

		if( $DBObject::vtypes{ $p{$key}{type} }{aedit} ){
			$val = $DBObject::vtypes{ $p{$key}{type} }{aedit}->($key,$val,$o);
		}

		$o->{$key} = $val;
	}

	$o->{'_print'} = "Успешно сохранено.<br>\n";
}

sub file_href
{
	my $o = shift;
	my $name = shift;
	my $id = $o->{ID};
	my %props = $o->props();

	return '/files/'.ref($o)."_${name}_$id".$props{$name}{ext};

}

sub aview
{
	my $o = shift;
	my $key;
	my %p = $o->props();
	if($main::gid != 0){ main::err403("DBO: VIEW with gid != 0,".ref($o).", ".$o->{ID}); }

	print "\n\n";
	print "<table border=0><tr><td align=center>";
	print "<!-- VIEW '".ref($o)."' WHERE ID = $o->{ID} -->\n";
	if($o->{'_print'}){ print $o->{'_print'}; $o->{'_print'} = ''; }
	print '<form action="?act=edit" method="POST" enctype="multipart/form-data">',"\n";

	print '<input type="hidden" name="ID" value="',$o->{ID},'">',"\n";
	print '<input type="hidden" name="act" value="edit">',"\n";
	print '<table>',"\n";

	for $key (keys( %p )){

		print "<tr><td valign=top>".$p{$key}{name}.":</td><td>\n";
		print $DBObject::vtypes{ $p{$key}{type} }{aview}->( $key, $o->{$key}, $o );
		print "\n</td>\n</tr>\n";
	}

	print "<tr>\n  <td>\n  </td>\n  <td align=right>\n";
	print "    <input type=submit value=Сохранить>\n";
	print "  </td>\n</tr>\n";

	print "</table>\n";
	print "</form>\n\n";
	print "  </td>\n</tr>\n</table>";

}

sub del
{
	my $o = shift;
	my $key;
	my %p = $o->props();
	if($main::gid != 0){ main::err403("DBO: DELETE with gid != 0,".ref($o).", ".$o->{ID}); }

	for $key (keys( %p )){
		
		if( $DBObject::vtypes{ $p{$key}{type} }{del} ){
			
			$DBObject::vtypes{ $p{$key}{type} }{del}->( $key, $o->{$key}, $o );
			
		}
		
	}

	my $str = $main::dbh->prepare('DELETE FROM `dbo_'.ref($o).'` WHERE ID = ? LIMIT 1');
	$str->execute($o->{ID});

	$o->clear();

}

sub sel
{
	my $o = shift;
	my $wh = shift;

	my $id;

	$o->save();
	$o->clear();

	my $str = $main::dbh->prepare('SELECT ID FROM `dbo_'.ref($o).'` WHERE '.$wh);
	$str->execute(@_);

	($id) = $str->fetchrow_array();

	if(! $id){ return; }

	$o->{ID} = $id;
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

sub reload
{
	my $o = shift;
	my $key;
	my %p = $o->props();


	if($o->{ID} < 0){ return; }
	if($o->{ID} =~ m/\D/){ main::err505('DBO: Non-digital ID passed to reload(), '.ref($o).", $o->{ID}"); }

	my $sql = 'SELECT * FROM `dbo_'.ref($o).'` WHERE ID = ? LIMIT 1';

	my $str = $main::dbh->prepare($sql);
	$str->execute($o->{ID});

	my $res = $str->fetchrow_hashref('NAME_lc');

	if($res->{id} != $o->{ID}){ main::err505('DBO: Loading from not existed row, class = "'.ref($o).'",ID = '.$o->{ID}); }

	my $id = 0;
	my $have_o = 0;

	for $key (keys( %p )){
		$o->{$key} = $res->{$key};

		if( $p{$key}{type} eq 'object' ){

			$have_o = 1;

			$id = $o->{$key};
			if($id < 1){ $id = 'cre' }
			$o->{$key} = &{ 'main::'.$p{$key}{class}.'::new' }($id);
			$o->{$key}->{PAPA_ID} = $o->{ID};
			$o->{$key}->{PAPA_CLASS} = ref($o);
		}
	}

	$o->{PAPA_ID} = $res->{papa_id};
	$o->{PAPA_CLASS} = $res->{papa_class};

	if($have_o == 1){ $o->save() }

}

sub papa
{
	my $o = shift;

	if($o->{PAPA_CLASS} eq '' or $o->{PAPA_ID} < 0){ return undef; }

	return &{ 'main::'.$o->{PAPA_CLASS}.'::new' }($o->{PAPA_ID});
}

sub tree
{
	my $o = shift;

	my @all;
	my $count = 0;

	do{
		$count++;
		unshift(@all, '<a '.$EML::dbo::emlh.' href=?class='.ref($o).'&ID='.$o->{ID}.'>'.$o->name().'</a>');

	}while($o = $o->papa() and $count < 50);

	print join(' :: ',@all);

}

sub saveAs
{
	my $o = shift;
	my $n = shift;
	my $t = 0;

	$o->{ID} = $o->saveTo($n);

	return $n;
}

sub saveTo
{
	my $o = shift;
	my $n = shift;
	my $t = 0;

	if($n eq 'cre'){ $n = $o->insert(); }

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

	if($n eq 'cre'){ $n = $o->insert(); }

	$o->{ID} = $n;
	$o->reload();

}

sub load
{
	my $o = shift;
	my $n = shift;

	$o->save();
	$o->clear();

	if($n eq 'cre'){ $n = $o->insert(); }

	$o->{ID} = $n;
	$o->reload();

}

sub save {
	my $o = shift;
	my $key;
	my %p = $o->props();
	my @vals = ();

	if($o->{ID} < 0){ return; }

	#print "SAVE: ".ref($o)."<br>";

	my $sql = 'UPDATE `dbo_'.ref($o).'` SET ';

	my $val;

	$sql .= 'PAPA_ID = ?, PAPA_CLASS = ?, ';

	for $key (keys( %p )){
		$sql .= "\n $key = ?,";

		if( $p{$key}{type} eq 'object' ){

			$o->{$key}->save();
			$val = $o->{$key}->{ID};

			#print 'Son ID: '.$val.'<br>';
		}
		else{ $val = $o->{$key}; }

		push @vals, $val;

	}

	chop($sql);

	$sql .=  "\n".' WHERE ID = ? LIMIT 1';

	my $str = $main::dbh->prepare($sql);
	$str->execute($o->{PAPA_ID},$o->{PAPA_CLASS},@vals,$o->{ID});

}

sub insert
{
	my $o = shift;	
	my $str;

	$str = $main::dbh->prepare('INSERT INTO `dbo_'.ref($o).'` () VALUES ()');
	$str->execute();

	$str = $main::dbh->prepare('SELECT LAST_INSERT_ID() FROM `dbo_'.ref($o).'` LIMIT 1');
	$str->execute();
	my $id;

	($id) = $str->fetchrow_array();

	return $id;

}

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

sub creTABLE
{
	my $o = shift;
	my $key;
	my %p = $o->props();

	my $sql = 'CREATE TABLE `dbo_'.ref($o).'` ( '."\n";
	$sql .= '`ID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY , '."\n";
	$sql .= '`PAPA_ID` INT DEFAULT \'-1\' NOT NULL, '."\n";
	$sql .= '`PAPA_CLASS` VARCHAR(20) NOT NULL, '."\n";

	for $key (keys( %p )){
		$sql .= " `$key` ".$DBObject::vtypes{ $p{$key}{type} }{table_cre}->($p{$key}).' NOT NULL , '."\n";
	}
	$sql =~ s/,\s*$//;
	$sql .= "\n )";

	my $str = $main::dbh->prepare($sql);
	$str->execute();

	$sql =~ s/\n/<br>\n/g;

	print $sql;
	print '<br>';
}

sub DESTROY
{
	my $o = shift;
	#$o->{DESTR} = 1;
	$o->save();
}



require $main::jlib.'/dbo_vtypes.cgi';

return 1;


