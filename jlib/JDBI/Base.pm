# (�) ������ �.�., 2005

package JDBI::Base;
use strict qw(subs vars);

###################################################################################################
# ��������� ����
###################################################################################################

our %sys_cols =
(
	'ID'			=> 'INT NOT NULL AUTO_INCREMENT PRIMARY KEY',
	'OID'			=> 'INT DEFAULT \'0\' NOT NULL',
	'ATS'			=> 'TIMESTAMP NOT NULL',
	'CTS'			=> 'TIMESTAMP NOT NULL',
	#'SHCUT'			=> 'INT DEFAULT \'0\' NOT NULL',
	'PAPA_ID'		=> 'INT DEFAULT \'0\' NOT NULL',
	'PAPA_CLASS'	=> 'CHAR(40) NOT NULL'
);


###################################################################################################
# ��������� ������ ��������� � ����������
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
# ������ ����������� ����� ��������
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
# ������ ��� ���������������� ������ � ����� ������
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
	
	unless($o->{'ID'}){ $o->clear(); return; }
	if($o->{'ID'} =~ m/\D/){ JIO::err505('DBO: Non-digital ID passed to del(), '.ref($o).', '.$o->{'ID'}); }
	
	my $papa = $o->papa();
	if(!$papa)
	{
		if(!$o->access('w')){ $o->err_add('� ��� ��� ���������� �������� ���� �������.'); return; }
	}
	else
	{
		if(!$papa->access('x')){ $o->err_add('� ��� ��� ���������� �������� �������� ����� ��������.'); return; }
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
	my $p = $o->props();
	my $res;
	
	if($o->{'ID'})
	{
		if($o->{'ID'} =~ m/\D/){ JIO::err505('DBO: Non-digital ID passed to reload(), '.ref($o).", $o->{'ID'}"); }
		
		my $str = $JDBI::dbh->prepare('SELECT * FROM `dbo_'.ref($o).'` WHERE ID = ? LIMIT 1');
		$str->execute($o->{'ID'});
		
		$res = $str->fetchrow_hashref('NAME_lc');
		
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
	}
	
	unless($o->access('r')){ $res = {}; }
	
	my $vt;
	for my $key (keys( %$p ))
	{
		$vt = 'JDBI::vtypes::'.$p->{$key}{'type'};
		
		if(${$vt.'::virtual'}){ next }
		
		if(${$vt.'::filter'})
		{
			$o->{$key} = $vt->filter_load($key,$res->{$key},$o);
		}
		else
		{
			$o->{$key} = $res->{$key};
		}
	}
	
	if($o->{'_save_after_reload'}){ $o->save() }
}

sub save
{
	my $o = shift;
	my $p = $o->props();
	my @vals = ();
	my $val;
	
	unless($o->{'ID'}){ return; }
	unless($o->access('w')){ return; }
	if($o->{'ID'} =~ m/\D/){ JIO::err505('DBO: Non-digital ID passed to save(), '.ref($o).', '.$o->{'ID'}); }
	
	#print 'Saving: ',$o->myurl(),'<br>';
	
	my $sql = 'UPDATE `dbo_'.ref($o).'` SET ';
	$sql .= ' OID = ?, PAPA_ID = ?, PAPA_CLASS = ?';
	
	my $vt;
	for my $key (keys( %$p ))
	{
		$vt = 'JDBI::vtypes::'.$p->{$key}{'type'};
		
		if(${$vt.'::virtual'}){ next }
		
		$sql .= ",\n $key = ? ";
		
		if(${$vt.'::filter'})
		{
			$val = $vt->filter_save($key,$o->{$key},$o);
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
	my $c = shift;
	
	my $id = $c->insertid();
	my $p = $c->props();
	my (@vals,$val,@flds,$sql);
	
	$sql = 'UPDATE `dbo_'.$c.'` SET ';
	
	my $vt;
	for my $key (keys( %$p ))
	{
		$vt = 'JDBI::vtypes::'.$p->{$key}{'type'};
		
		if(${$vt.'::virtual'}){ next }
		unless(${$vt.'::filter'}){ next }
		
		$val = $vt->filter_insert($key,$c);
		
		push @flds," $key = ? ";
		push @vals, $val;
	}
	
	$sql .= join(', ',@flds).' WHERE ID = ? LIMIT 1';
	
	if(@flds)
	{
		my $str = $JDBI::dbh->prepare($sql);
		$str->execute(@vals,$id);
	}
	
	return $id;
}

sub insertid
{
	my $c = shift;
	my $str;
	
	$str = $JDBI::dbh->prepare('INSERT INTO `dbo_'.$c.'` (OID,CTS) VALUES (?,NOW())');
	$str->execute($JDBI::user->{'ID'});
	
	$str = $JDBI::dbh->prepare('SELECT LAST_INSERT_ID() FROM `dbo_'.$c.'` LIMIT 1');
	$str->execute();
	
	my ($id) = $str->fetchrow_array();
	
	return $id;
}


###################################################################################################
# ��������������� ������ ������ � ����� ������
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
	
	# �������� �� ��������� ����
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
				print '���������� ',$c,': ',$cols{$c},' => ',$csql,'<br>';
				$JDBI::dbh->do('ALTER TABLE '.$tbl.' CHANGE `'.$c.'` `'.$c.'` '.$csql.' NOT NULL ');
			}
		}
	}
	
	# �������� �� ����� ����
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
				print '����������: ',$c,' ',$csql,'<br>';
				$JDBI::dbh->do('ALTER TABLE '.$tbl.' ADD `'.$c.'` '.$csql.' NOT NULL ');
			}
		}
	}
	
	# �������� �� �������� ����
	for $c (keys(%cols))
	{
		unless($p->{$c})
		{
			$change = 1;
			unless($test)
			{
				print '���������: ',$c,'<br>';
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