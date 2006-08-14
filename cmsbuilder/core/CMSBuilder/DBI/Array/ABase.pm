# CMSBuilder © Леонов П. А., 2005-2006

package CMSBuilder::DBI::Array::ABase;
use strict qw(subs vars);
use utf8;

use Carp;

use CMSBuilder;
use CMSBuilder::IO;
use CMSBuilder::Utils;
use CMSBuilder::DBI;

sub get_interval
{
	my $o = shift;
	my $beg = shift;
	my $end = shift;
	my $where = shift;
	
	return if $end < $beg || $beg < 1;
	return $o->err_add('У Вас нет разрешений просматривать этот элемент.') unless $o->access('r');
	return unless $o->array_table_exists;
	
	my($sql,$ref,$str,$str2,@oar,$to);
	
	$sql = 'SELECT * FROM ' . $o->array_tblname() . ' WHERE num >= ?' . ($where && ' AND ' . $where) . ' LIMIT ' . ($end-$beg+1);
	
	$str = $dbh->prepare($sql);
	$str->execute($beg,@_);
	
	while($ref = $str->fetchrow_hashref)
	{
		$to = cmsb_url($ref->{'OBJURL'});
		
		unless($to && $to->id)
		{
			$dbh->do('DELETE FROM '.$o->array_tblname().' WHERE num = ? LIMIT 1',undef,$ref->{'num'});
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
	return $o->err_add('У Вас нет разрешения добавлять элементы в этот массив.') unless $o->access('a');
	
	return unless $o->id;
	return unless $po->id;
	$o->create_array_table() unless $o->array_table_exists;
	
	unless($o->elem_can_paste($po)){ CMSBuilder::IO::err500('Trying to add element with classname "'.ref($po).'", to array "'.ref($o).'"'); }
	
	my $str;
	
	if($o->pages_direction())
	{
		$str = $dbh->prepare('INSERT INTO '.$o->array_tblname().' (OBJURL) VALUES (?)');
	}
	else
	{
		$dbh->do('UPDATE '.$o->array_tblname().' SET num = num + 1');
		$str = $dbh->prepare('INSERT INTO '.$o->array_tblname().' (num,OBJURL) VALUES (1,?)');
	}
	
	$str->execute($po->myurl);
	
	$o->array_sort_table();
}

sub elem_tell_enum
{
	my $o = shift;
	my $to = shift;
	
	return $o->err_add('У Вас нет разрешений просматривать этот элемент.') unless $o->access('r');
	
	return unless $o->id;
	return unless $o->array_table_exists;
	
	carp "Wrong object passed: '$to'" && return unless $to && ref $to && $to->myurl;
	
	my $str = $dbh->prepare('SELECT num FROM '.$o->array_tblname().' WHERE OBJURL = ? LIMIT 1');
	$str->execute($to->myurl);
	
	my ($res) = $str->fetchrow_array();
	
	return $res || 0;
}

sub elem
{
	my $o = shift;
	my $enum = shift;
	
	my ($to) = $o->get_interval($enum,$enum);
	
	$^W && warn 'Trying to get not existed element "' . $enum . '", from "' . $o->myurl() . '"'."\n" unless $to;
	
	return $to;
}

sub elem_cut
{
	my $o = shift;
	my $obj = shift;
	unless($o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
	
	return unless $o->id;
	
	my $to = ref($obj) ? $obj : $o->elem($obj);
	return unless $to && $to->access('w');
	
	$dbh->do('DELETE FROM '.$o->array_tblname.' WHERE OBJURL = ?',undef,$to->myurl);
	$o->array_sort_table();
	
	return $to;
}

sub elem_moveto
{
	my $o = shift;
	my $enum = shift;
	my $place = shift;
	if(!$o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
	
	return unless $o->id;
	
	if($place eq ''){ $o->err_add('Новая позиция пуста.'); return; }
	if($place < 0){ $o->err_add('Новая позиция меньше 1.'); return; }
	#if($place == $enum){ $o->err_add('Новая позиция равна старой.'); return; }
	if($place > $o->len()){ $o->err_add('Новая позиция больше или равна количеству элементов ('.$place.').'); return; }
	
	my $elem = $o->elem($enum);
	unless($elem){ $o->err_add('Указанный элемент не существует ('.$enum.').'); return; }
	
	$o->array_sort_table();
	
	my $str = $dbh->prepare( 'UPDATE '.$o->array_tblname().' SET num = num+1 WHERE num > '.$place );
	$str->execute();
	
	$str = $dbh->prepare( 'UPDATE '.$o->array_tblname().' SET `num` = ? WHERE `num` = ? LIMIT 1' );
	
	if($enum > $place)
	{
		$str->execute($place+1,$enum+1);
	}
	else
	{
		$str->execute($place+1,$enum);
	}
	
	$o->array_sort_table();
}


#————————————————— Методы для оптимизации использования таблиц —————————————————

sub create_array_table
{
	my $o = shift;
	
	my $sql = 'CREATE TABLE '.$o->array_tblname().' ( '
	. '`num` INT NOT NULL AUTO_INCREMENT , '
	. '`OBJURL` CHAR(255) DEFAULT \'\' NOT NULL, '
	. '`ATS` DATETIME NOT NULL, '
	. '`CTS` DATETIME NOT NULL, '
	. '`NAME` CHAR(10) NOT NULL, '
	. 'INDEX ( `num` ),INDEX ( `OBJURL` ) )';
	
	$dbh->do($sql);
	
	$o->{'__array_table_exists'} = 1;
}

sub array_table_exists
{
	my $o = shift;
	
	return unless $o->id;
	return $o->{'__array_table_exists'} if exists $o->{'__array_table_exists'};
	
	return $o->{'__array_table_exists'} = CMSBuilder::DBI::table_exists($o->array_tblname());
}


#——————————————— Методы для непосредственной работы с Базой Данных —————————————

sub len
{
	my $o = shift;
	my $where = shift;
	
	return 0 unless $o->id && $o->array_table_exists && $o->access('r');
	
	my $str = $dbh->prepare('SELECT COUNT(*) AS LEN FROM '.$o->array_tblname().($where?' WHERE '.$where:''));
	$str->execute();
	
	my ($res) = $str->fetchrow_array();
	
	return $res;
}

sub del
{
	my $o = shift;
	
	return unless $o->id;
	unless($o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
	
	unless($o->{'SHCUT'})
	{
		map { $o->elem_del(1) } $o->get_all();
		
		if($o->array_table_exists)
		{
			$dbh->do('DROP TABLE '.$o->array_tblname);
		}
	}
	
	return $o->CMSBuilder::DBI::Object::del();
}

sub array_sort_table
{
	my $o = shift;
	my $by = shift;
	
	return unless $o->id;
	return unless $o->array_table_exists;
	
	$by =~ s/\W//;
	$by ||= 'num';
	
	my $tbl = $o->array_tblname;
	
	$dbh->do('ALTER TABLE ' . $tbl . ' ORDER BY `' . $by . '`;');
	$dbh->do('SET @cnt:=0;');
	$dbh->do('UPDATE ' . $tbl . ' SET num = @cnt:=@cnt+1;');
}

sub array_sort_reverse
{
	my $o = shift;
	my $len = $o->len;
	
	$dbh->do('UPDATE ' . $o->array_tblname() . ' SET num = ' . $len . ' - num + 1');
	
	$o->array_sort_table();
}

sub array_tblname
{
	my $o = shift;
	
	my $tn = ref $o;
	$tn =~ s/::/-/g;
	
	return '`' . $CMSBuilder::Config::table_name_pfx . 'cmsbarr-' . $tn . ($o->{'SHCUT'} || $o->id || 0) . '`';
}


1;