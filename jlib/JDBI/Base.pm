# (с) Леонов П.А., 2005

package JDBI::Base;
use strict qw(subs vars);

###################################################################################################
# Системные поля
###################################################################################################

our %sys_cols =
(
	'ID'			=> 'INT NOT NULL AUTO_INCREMENT PRIMARY KEY',
	'OID'			=> 'INT DEFAULT \'-1\' NOT NULL',
	'ATS'			=> 'TIMESTAMP NOT NULL',
	'CTS'			=> 'TIMESTAMP NOT NULL',
	#'SHCUT'			=> 'INT DEFAULT \'0\' NOT NULL',
	'PAPA_ID'		=> 'INT DEFAULT \'0\' NOT NULL',
	'PAPA_CLASS'	=> 'VARCHAR(20) NOT NULL'
);


###################################################################################################
# Следующие методы находятся в разработке
###################################################################################################

sub shcut_cre
{
	my $o = shift;
	my $nobase = shift;
	my $tsh;
	
	$tsh = $nobase?ShortCut->new():ShortCut->cre();
	
	$tsh->{'obj_id'}	= $o->{'ID'};
	$tsh->{'obj_class'}	= ref($o);
	$tsh->{'_o'}		= $o;
	
	unless($nobase){ $tsh->save(); }
	
	return $tsh;
}


###################################################################################################
# Методы выполняющие поиск объектов
###################################################################################################

sub sel_one
{
	my $class = shift;
	my $wh = shift;
	
	my $str = $JDBI::dbh->prepare('SELECT ID FROM `dbo_'.$class.'` WHERE '.$wh.' LIMIT 1');
	$str->execute(@_);
	
	my ($id) = $str->fetchrow_array();
	
	if(!$id){ return undef; }
	
	return $class->new($id);
}

sub sel_where
{
	my $class = shift;
	my $wh = shift;

	my($id,@oar);

	my $str = $JDBI::dbh->prepare('SELECT ID FROM `dbo_'.$class.'` WHERE '.$wh);
	$str->execute(@_);
	
	while( ($id) = $str->fetchrow_array() )
	{
		push @oar,$class->new($id);
	}
	
	return @oar;
}

sub sel_sql
{
	my $class = shift;
	my $sql = shift;
	
	my $res;
	my @oar;
	
	my $str = $JDBI::dbh->prepare($sql);
	$str->execute(@_);
	
	while( $res = $str->fetchrow_hashref('NAME_lc') ){ push(@oar,$class->new($res->{'id'})) }
	
	return @oar;
}


###################################################################################################
# Методы для непосредственной работы с Базой Данных
###################################################################################################

sub count
{
	my $c = shift;
	
	my $str = $JDBI::dbh->prepare('SELECT COUNT(ID) FROM `dbo_'.$c.'`');
	$str->execute();
	
	my ($res) = $str->fetchrow_array();
	
	return $res;
}

sub del
{
	my $o = shift;
	my $key;
	my $p = $o->props();
	
	if($o->{'ID'} < 1){ $o->clear(); return; }
	if($o->{'ID'} =~ m/\D/){ JIO::err505('DBO: Non-digital ID passed to del(), '.ref($o).', '.$o->{'ID'}); }
	
	my $papa = $o->papa();
	if(!$papa)
	{
		if(!$o->access('w')){ $o->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
	}
	else
	{
		if(!$papa->access('x')){ $o->err_add('У Вас нет разрешения изменять родителя этого элемента.'); return; }
	}
	
	for $key (keys( %$p ))
	{
		my $vtype = 'JDBI::vtypes::'.$p->{$key}{'type'};
		$vtype->del( $key, $o->{$key}, $o );
	}
	
	my $str = $JDBI::dbh->prepare('DELETE FROM `dbo_'.ref($o).'` WHERE ID = ? LIMIT 1');
	$str->execute($o->{'ID'});
	
	$o->clear();
}

sub reload
{
	my $o = shift;
	my $key;
	my $p = $o->props();
	
	if($o->{'ID'} < 1){ return; }
	if($o->{'ID'} =~ m/\D/){ JIO::err505('DBO: Non-digital ID passed to reload(), '.ref($o).", $o->{'ID'}"); }
	
	my $str = $JDBI::dbh->prepare('SELECT * FROM `dbo_'.ref($o).'` WHERE ID = ? LIMIT 1');
	$str->execute($o->{'ID'});
	
	my $res = $str->fetchrow_hashref('NAME_lc');
	
	if($res->{'id'} != $o->{'ID'})
	{
		print STDERR 'DBO: Loading from not existed row, class = "'.ref($o).'",ID = '.$o->{'ID'}."\n";
		if($JConfig::lfnexrow_error505){ JIO::err505('exrow_error'); }
		$o->clear();
		return;
	}
	
	$o->{'PAPA_ID'} = $res->{'papa_id'};
	$o->{'PAPA_CLASS'} = $res->{'papa_class'};
	$o->{'OID'} = $res->{'oid'};
	$o->{'CTS'} = $res->{'cts'};
	$o->{'ATS'} = $res->{'ats'};
	$o->{'SHCUT'} = $res->{'shcut'};
	
	unless($o->access('r')){ return; }
	
	my $id = 0;
	my $have_o = 0;
	
	for $key (keys( %$p ))
	{
		if(${'JDBI::vtypes::'.$p->{$key}{'type'}.'::virtual'}){ next }
		
		$o->{$key} = $res->{$key};
		
		if( $p->{$key}{'type'} eq 'object' )
		{
			$id = $o->{$key};
			if($id < 1)
			{
				$o->{$key} = $p->{$key}{'class'}->cre();
				$o->{$key}->{'PAPA_ID'} = $o->{'ID'};
				$o->{$key}->{'PAPA_CLASS'} = ref($o);
				$o->{$key}->save();
				$have_o = 1;
			}
			else
			{
				$o->{$key} = $p->{$key}{'class'}->new($id);
			}
			
			$o->{$key}->{'_is_property'} = 1;
		}
	}
	
	if($have_o == 1){ $o->save() }
}

sub save
{
	my $o = shift;
	my $key;
	my $p = $o->props();
	my @vals = ();
	my $val;
	
	if(!exists $o->{'ID'} or $o->{'ID'} < 1){ return; }
	if(!$o->access('w')){ return; }
	if($o->{'ID'} =~ m/\D/){ JIO::err505('DBO: Non-digital ID passed to save(), '.ref($o).', '.$o->{'ID'}); }
	
	#print 'Saving: ',$o->myurl(),'<br>';
	
	my $sql = 'UPDATE `dbo_'.ref($o).'` SET ';
	$sql .= ' OID = ?, PAPA_ID = ?, PAPA_CLASS = ?';#SHCUT = ?, 
	
	for $key (keys( %$p ))
	{
		if(${'JDBI::vtypes::'.$p->{$key}{'type'}.'::virtual'}){ next }
		
		$sql .= ",\n $key = ? ";
		
		#if( ${ 'JDBI::vtypes::'.$p->{$key}{'type'}.'::filter' }){ 1; }
		
		if( $p->{$key}{'type'} eq 'object' )
		{
			if($o->{$key})
			{
				$o->{$key}->save();
				$val = $o->{$key}->{'ID'};
			}
			else
			{
				$val = 0;
			}
		}
		else
		{
			$val = $o->{$key};
		}
		
		push @vals, $val;
	}
	
	$sql .=  "\n".' WHERE ID = ? LIMIT 1';
	
	my $str;
	$str = $JDBI::dbh->prepare($sql);
	$str->execute($o->{'OID'},$o->{'PAPA_ID'},$o->{'PAPA_CLASS'},@vals,$o->{'ID'});
}

sub insert
{
	my $o = shift;
	my $str;
	
	$str = $JDBI::dbh->prepare('INSERT INTO `dbo_'.ref($o).'` (OID,CTS) VALUES (?,NOW())');
	$str->execute($JDBI::user->{'ID'});
	
	$str = $JDBI::dbh->prepare('SELECT LAST_INSERT_ID() FROM `dbo_'.ref($o).'` LIMIT 1');
	$str->execute();
	my $id;
	
	($id) = $str->fetchrow_array();
	
	return $id;
}


###################################################################################################
# Вспомогательные методы работы с Базой Данных
###################################################################################################

sub check
{
	my $class = shift;
	
	my $p = $class->props();
	my @aview = $class->aview();
	
	my $i;
	for $i (0 .. $#aview)
	{
		unless($p->{$aview[$i]})
		{
			print STDERR "\n",'@'.$class.'->aview() contain prop ',$aview[$i],' not existed in props.',"\n";
			splice(@aview,$i,1)
		}
	}
	
	#print STDERR '[@'.$class.'->aview() checked]';
}

sub load
{
	my $o = shift;
	my $n = shift;
	
	$o->clear();
	
	$o->{'ID'} = $n;
	$o->reload();
}

sub clear
{
	my $o = shift;
	delete $JDBI::dbo_cache{ref($o).$o->{'ID'}};
	
	%$o = ();
	$o->{'ID'} = 0;
}

sub clear_data
{
	my $o = shift;
	my $key;
	my $p = $o->props();
	
	for $key (keys( %$p )){ $o->{$key} = ''; }
}

sub table_have
{
	my $class = shift;
	my($tn1,$tn2) = (lc('`dbo_'.$class.'`'),lc('dbo_'.$class));
	my $rt;
	
	my $tbl;
	for $tbl ($JDBI::dbh->tables())
	{
		$rt = lc($tbl);
		if( $tn1 eq $rt or $tn2 eq $rt){ return 1 }
	}
	
	return 0;
}

sub table_fix
{
	my $class = shift;
	my $test = shift;
	my($str,$r,%cols,$c,$p,$vtype,$csql,$change,$tbl);
	
	$tbl = '`dbo_'.$class.'`';
	$p = $class->props();
	
	$str = $JDBI::dbh->prepare('DESCRIBE '.$tbl);
	$str->execute();
	
	while($r = $str->fetchrow_arrayref() )
	{
		if($sys_cols{$r->[0]}){ next; }
		$cols{$r->[0]} = $r->[1];
		$cols{$r->[0]} =~ s/\s//g;
	}
	
	# проверка на изменение типа
	for $c (keys(%cols))
	{
		unless($p->{$c}){ next; }
		$vtype = 'JDBI::vtypes::'.$p->{$c}{'type'};
		$csql = $vtype->table_cre($p->{$c});
		$csql =~ s/\s//g;
		
		if(uc($cols{$c}) ne uc($csql))
		{
			$change = 1;
			unless($test)
			{
				print 'Изменилось ',$c,': ',$cols{$c},' => ',$csql,'<br>';
				$JDBI::dbh->do('ALTER TABLE '.$tbl.' CHANGE `'.$c.'` `'.$c.'` '.$csql.' NOT NULL ');
			}
		}
	}
	
	# проверка на новые поля
	for $c (keys(%$p))
	{
		$vtype = 'JDBI::vtypes::'.$p->{$c}{'type'};
		$csql = $vtype->table_cre($p->{$c});
		$csql =~ s/\s//g;
		
		unless($cols{$c})
		{
			$change = 1;
			unless($test)
			{
				print 'Добавилось: ',$c,' ',$csql,'<br>';
				$JDBI::dbh->do('ALTER TABLE '.$tbl.' ADD `'.$c.'` '.$csql.' NOT NULL ');
			}
		}
	}
	
	# проверка на удалённые поля
	for $c (keys(%cols))
	{
		unless($p->{$c})
		{
			$change = 1;
			unless($test)
			{
				print 'Удалилось: ',$c,'<br>';
				$JDBI::dbh->do('ALTER TABLE '.$tbl.' DROP `'.$c.'`');
			}
		}
	}
	
	return $change;
}

sub table_cre
{
	my $class = shift;
	my($key,$p,$vtype,$sc);
	
	$p = $class->props();
	
	my $sql = 'CREATE TABLE IF NOT EXISTS `dbo_'.$class.'` ( '."\n";
	
	for $sc (sort(keys(%sys_cols)))
	{
		$sql .= '`'.$sc.'` '.$sys_cols{$sc}.', '."\n";
	}
	
	for $key (keys(%$p))
	{
		$vtype = 'JDBI::vtypes::'.$p->{$key}{'type'};
		
		if( !${$vtype.'::virtual'} )
		{
			$sql .= " `$key` ".$vtype->table_cre($p->{$key}).' NOT NULL , '."\n";
		}
	}
	$sql =~ s/,\s*$//;
	$sql .= "\n )";
	
	my $str = $JDBI::dbh->prepare($sql);
	if($str->execute())
	{
		$sql =~ s/\n/<br>\n/g;
		return $sql;
	}
	else
	{
		return 0;
	}
}

1;