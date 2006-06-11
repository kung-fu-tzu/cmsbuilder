# (с) Леонов П.А., 2005

package CMSBuilder::DBI::Array::ABase;
use strict qw(subs vars);

#———————————————————————————————————————————————————————————————————————————————

use CMSBuilder;
use CMSBuilder::IO;
use CMSBuilder::Utils;

###################################################################################################
# Основные методы для работы с элементами массива
###################################################################################################

sub get_interval
{
	my $o = shift;
	my $beg = shift;
	my $end = shift;
	my $where = shift;
	
	if($end < $beg or $beg < 1){ return (); }
	unless($o->access('r')){ $o->err_add('У Вас нет разрешений просматривать этот элемент.'); return (); }
	unless($o->is_array_table()){ return (); }
	
	my($sql,$ref,$str,$str2,@oar,$to);
	
	$sql = 'SELECT CLASS,ID,num FROM '.$o->array_tblname().' WHERE num >= ? '.($where?' AND '.$where:'').' LIMIT '.($end-$beg+1);
	
	$str = $CMSBuilder::DBI::dbh->prepare($sql);
	$str->execute($beg,@_);
	
	while($ref = $str->fetchrow_arrayref())
	{
		$to = $ref->[0]->new($ref->[1]);
		
		$to->{'_ARRAY'} = ref($o);
		
		unless($to->{'ID'})
		{
			$CMSBuilder::DBI::dbh->do('DELETE FROM '.$o->array_tblname().' WHERE num = ? LIMIT 1',undef,$ref->[2]);
			$sess->{'admin_refresh_left'} = 1;
			next;
		}
		
		next unless $to->access('r');
		
		push @oar,$to;
	}
	#print $sql;
	return @oar;
}

sub elem_paste_ref
{
	my $o = shift;
	my $po = shift;
	unless($o->access('a')){ $o->err_add('У Вас нет разрешения добавлять в этот элемент.'); return; }
	
	unless($o->{'ID'} > 0){ return; }
	unless($po->{'ID'} > 0){ return; }
	unless($o->is_array_table()){ $o->create_array_table();  }
	
	unless($o->elem_can_paste($po)){ CMSBuilder::IO::err500('Trying to add element with classname "'.ref($po).'", to array "'.ref($o).'"'); }
	
	my $str;
	
	if($o->pages_direction())
	{
		$str = $CMSBuilder::DBI::dbh->prepare('INSERT INTO '.$o->array_tblname().' (ID,CLASS) VALUES (?,?)');
	}
	else
	{
		$CMSBuilder::DBI::dbh->do('UPDATE '.$o->array_tblname().' SET num = num + 1');
		$str = $CMSBuilder::DBI::dbh->prepare('INSERT INTO '.$o->array_tblname().' (num,ID,CLASS) VALUES (1,?,?)');
	}
	
	$str->execute($po->{'ID'},ref($po));
	
	$o->sortT();
}

sub elem_tell_enum
{
	my $o = shift;
	my $to = shift;
	
	unless($o->access('r')){ $o->err_add('У Вас нет разрешений просматривать этот элемент.'); return 0; }
	
	unless($o->{'ID'}){ return 0; }
	unless($o->is_array_table()){ return 0; }
	
	my $str = $CMSBuilder::DBI::dbh->prepare('SELECT num FROM '.$o->array_tblname().' WHERE CLASS = ? AND ID = ? LIMIT 1');
	$str->execute(ref($to),$to->{'ID'});
	
	my ($res) = $str->fetchrow_array();
	
	return $res || 0;
}

sub elem
{
	my $o = shift;
	my $enum = shift;
	
	my ($to) = $o->get_interval($enum,$enum);
	
	unless($to)
	{
		print STDERR 'Trying to get not existed element "'.$enum.'", from "'.$o->myurl().'"'."\n";
	}
	
	return $to;
}

sub elem_cut
{
	my $o = shift;
	my $eid = shift;
	unless($o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
	
	unless($o->{'ID'}){ return; }
	
	my $to = $o->elem($eid);
	unless($to){ return undef; }
	
	delete $to->{'_ENUM'};
	
	unless($to->access('w')){ $o->err_add('У Вас нет разрешения изменять вырезаемый элемент.'); return; }
	
	my $str = $CMSBuilder::DBI::dbh->prepare('DELETE FROM '.$o->array_tblname().' WHERE num = ? LIMIT 1');
	$str->execute($eid);
	
	$o->sortT();
	
	return $to;
}

sub elem_moveto
{
	my $o = shift;
	my $enum = shift;
	my $place = shift;
	if(!$o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
	
	unless($o->{'ID'}){ return; }
	
	if($place eq ''){ $o->err_add('Новая позиция пуста.'); return; }
	if($place < 0){ $o->err_add('Новая позиция меньше 1.'); return; }
	#if($place == $enum){ $o->err_add('Новая позиция равна старой.'); return; }
	if($place > $o->len()){ $o->err_add('Новая позиция больше или равна количеству элементов ('.$place.').'); return; }
	
	my $elem = $o->elem($enum);
	unless($elem){ $o->err_add('Указанный элемент не существует ('.$enum.').'); return; }
	
	$o->sortT();
	
	my $str = $CMSBuilder::DBI::dbh->prepare( 'UPDATE '.$o->array_tblname().' SET num = num+1 WHERE num > '.$place );
	$str->execute();
	
	$str = $CMSBuilder::DBI::dbh->prepare( 'UPDATE '.$o->array_tblname().' SET `num` = ? WHERE `num` = ? LIMIT 1' );
	
	if($enum > $place)
	{
		$str->execute($place+1,$enum+1);
	}
	else
	{
		$str->execute($place+1,$enum);
	}
	
	$o->sortT();
}


###################################################################################################
# Методы для оптимизации использования таблиц
###################################################################################################

sub create_array_table
{
	my $o = shift;
	
	my $sql = 'CREATE TABLE '.$o->array_tblname().' ( '
	. '`num` INT NOT NULL AUTO_INCREMENT , '
	. '`ID` INT DEFAULT \'-1\' NOT NULL, '
	. '`CLASS` CHAR(40) NOT NULL, '
	. '`ATS` DATETIME NOT NULL, '
	. '`CTS` DATETIME NOT NULL, '
	. '`NAME` CHAR(10) NOT NULL, '
	. 'INDEX ( `num` ),INDEX ( `ID` ),INDEX ( `CLASS` ) )';
	
	my $str = $CMSBuilder::DBI::dbh->prepare($sql);
	$str->execute();
	
	$o->{'_isatable'} = 1;
}

sub is_array_table
{
	my $o = shift;
	
	unless($o->{'ID'}){ return 0; }
	if(exists $o->{'_isatable'}){ return $o->{'_isatable'}; }
	
	return $o->{'_isatable'} = CMSBuilder::DBI::table_exists($o->array_tblname());
}


###################################################################################################
# Методы для непосредственной работы с Базой Данных
###################################################################################################

sub len
{
	my $o = shift;
	my $where = shift;
	
	unless($o->{'ID'}){ return 0; }
	unless($o->is_array_table()){ return 0; }
	unless($o->access('r')){ return 0; }
	
	my $str = $CMSBuilder::DBI::dbh->prepare('SELECT COUNT(*) AS LEN FROM '.$o->array_tblname().($where?' WHERE '.$where:''));
	$str->execute();
	
	my ($res) = $str->fetchrow_array();
	
	return $res;
}

sub len_class
{
	my $o = shift;
	return $o->len($o->get_class_wheresql(@_));
}

sub del
{
	my $o = shift;
	
	unless($o->{'ID'}){ return; }
	
	my $papa = $o->papa();
	
	unless($o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
	
	unless($o->{'SHCUT'})
	{
		for my $i (1..$o->len()){ $o->elem_del(1); }
		
		if($o->is_array_table())
		{
			$CMSBuilder::DBI::dbh->do('DROP TABLE '.$o->array_tblname());
		}
	}
	
	return $o->CMSBuilder::DBI::Object::del();
}

sub sortT
{
	my $o = shift;
	my $by = shift;
	my($i,$table);
	
	unless($o->{'ID'} > 0){ return; }
	unless($o->is_array_table()){ return; }
	$by =~ s/\W//;
	unless($by){ $by = 'num'; }
	
	$table = $o->array_tblname();
	
	$CMSBuilder::DBI::dbh->do('ALTER TABLE '.$table.' ORDER BY `'.$by.'`;');
	$CMSBuilder::DBI::dbh->do('SET @cnt:=0;');
	$CMSBuilder::DBI::dbh->do('UPDATE '.$table.' SET num = @cnt:=@cnt+1;');
}

sub reverse
{
	my $o = shift;
	my $len = $o->len();
	
	$CMSBuilder::DBI::dbh->do('UPDATE '.$o->array_tblname().' SET num = '.$len.' - num + 1');
	
	$o->sortT();
}

sub array_tblname
{
	my $o = shift;
	
	my $cn = ref($o);
	$cn =~ s/::/_/g;
	
	return '`arr_'.$cn.($o->{'SHCUT'} || $o->{'ID'} || 0).'`';
}

###################################################################################################
# Методы использующиеся при сортировке
###################################################################################################

sub update_name
{
	my $o = shift;
	my($i,$to);
	
	my $sth = $CMSBuilder::DBI::dbh->prepare('UPDATE '.$o->array_tblname().' SET NAME = ? WHERE num = ?');
	
	for($i=1;$i<=$o->len();$i++)
	{
		$to = $o->elem($i);
		$sth->execute(substr($to->name(),0,10),$i);
	}
}

sub update_ats_cts
{
	my $o = shift;
	my($str,$r,@cls,$oldid,$c,$sql,$tblc,$tbl,$ctbln);
	
	unless($o->len()){ return; }
	
	$oldid = $o->{'ID'};
	$o->{'ID'} .= 'copy'.MD5(rand());
	$tblc = $o->array_tblname();
	$o->create_array_table();
	$o->{'ID'} = $oldid;
	
	$tbl = $o->array_tblname();
	
	$str = $CMSBuilder::DBI::dbh->prepare('SELECT DISTINCT CLASS FROM '.$o->array_tblname());
	$str->execute();
	
	while(($r) = $str->fetchrow_array()){ push(@cls,$r); }
	
	for $c (@cls)
	{
		$ctbln = $c->object_tblname();
		
		$sql = "
		INSERT  INTO $tblc ( `CLASS`, `ID`, `ATS`, `CTS` ) 
		SELECT  '$c' AS `CLASS`, $ctbln.`ID`, $ctbln.`ATS`, $ctbln.`CTS`
		FROM $ctbln, $tbl
		WHERE $tbl.`ID` = $ctbln.`ID` AND $tbl.`CLASS` = '$c'
		";
		$CMSBuilder::DBI::dbh->do($sql);
	}
	
	$CMSBuilder::DBI::dbh->do("DELETE FROM `$tbl`");
	$CMSBuilder::DBI::dbh->do("INSERT INTO `$tbl` SELECT * FROM `$tblc`");
	$CMSBuilder::DBI::dbh->do("DROP TABLE `$tblc`");
}


1;