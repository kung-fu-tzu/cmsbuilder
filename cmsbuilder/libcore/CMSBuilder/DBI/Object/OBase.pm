# (с) Леонов П.А., 2005

package CMSBuilder::DBI::Object::OBase;
use strict qw(subs vars);

#-------------------------------------------------------------------------------


use plgnUsers;

###################################################################################################
# Системные поля
###################################################################################################

our %sys_cols =
(
	'ID'			=> 'INT NOT NULL AUTO_INCREMENT PRIMARY KEY',
	'OWNER'			=> 'CHAR(50) DEFAULT \'0\' NOT NULL',
	'ATS'			=> 'TIMESTAMP NOT NULL',
	'CTS'			=> 'TIMESTAMP NOT NULL',
	'PAPA_ID'		=> 'INT DEFAULT \'0\' NOT NULL',
	'PAPA_CLASS'	=> 'CHAR(50) NOT NULL',
	'SHCUT'			=> 'INT DEFAULT \'0\' NOT NULL'
);


###################################################################################################
# Следующие методы находятся в разработке
###################################################################################################

sub object_tblname
{
	my $tn = '`dbo_'.( ref($_[0]) || $_[0] ).'`';
	$tn =~ s/\:\:/\_/g;
	return $tn;
}


###################################################################################################
# Методы выполняющие поиск объектов
###################################################################################################

sub sel_one
{
	my $c = shift;
	my $wh = shift;
	
	my $str = $CMSBuilder::DBI::dbh->prepare('SELECT ID FROM '.$c->object_tblname().' WHERE '.$wh.' LIMIT 1');
	$str->execute(@_);
	
	my ($id) = $str->fetchrow_array();
	
	if(!$id){ return undef; }
	
	return $c->new($id);
}

sub sel_where
{
	my $c = shift;
	my $wh = shift;

	my($id,@oar);

	my $str = $CMSBuilder::DBI::dbh->prepare('SELECT ID FROM '.$c->object_tblname().' WHERE '.$wh);
	$str->execute(@_);
	
	while( ($id) = $str->fetchrow_array() )
	{
		push @oar,$c->new($id);
	}
	
	return @oar;
}

sub sel_sql
{
	my $c = shift;
	my $sql = shift;
	
	my $res;
	my @oar;
	
	my $str = $CMSBuilder::DBI::dbh->prepare($sql);
	$str->execute(@_);
	
	while( $res = $str->fetchrow_hashref('NAME_lc') ){ push(@oar,$c->new($res->{'id'})) }
	
	return @oar;
}


###################################################################################################
# Методы для непосредственной работы с Базой Данных
###################################################################################################

sub count
{
	my $c = shift;
	
	my $str = $CMSBuilder::DBI::dbh->prepare('SELECT COUNT(*) FROM '.$c->object_tblname());
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
	if($o->{'ID'} =~ m/\D/){ CMSBuilder::IO::err500('DBO: Non-digital ID passed to del(), '.ref($o).', '.$o->{'ID'}); }
	
	my $papa = $o->papa();
	unless($papa)
	{
		unless($o->access('w')){ $o->err_add('У Вас нет разрешений изменять этот элемент.'); return; }
	}
	
	unless($o->{'SHCUT'})
	{
		for $key (keys( %$p ))
		{
			my $vtype = 'CMSBuilder::DBI::vtypes::'.$p->{$key}{'type'};
			$vtype->del( $key, $o->{$key}, $o );
		}
	}
	
	my $str = $CMSBuilder::DBI::dbh->prepare('DELETE FROM '.$o->object_tblname().' WHERE ID = ? LIMIT 1');
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
		$res = $o->loadref($o->{'ID'});
		
		if($res->{'ID'} != $o->{'ID'})
		{
			print STDERR 'DBO: Loading from not existed row, class = "'.ref($o).'",ID = '.$o->{'ID'}."\n";
			if($CMSBuilder::Config::lfnexrow_error500){ CMSBuilder::IO::err404('nexrow_error'); }
			$o->clear();
			return;
		}
		
		$o->{'PAPA_ID'} = $res->{'PAPA_ID'};
		$o->{'PAPA_CLASS'} = $res->{'PAPA_CLASS'};
		$o->{'OWNER'} = $res->{'OWNER'};
		$o->{'CTS'} = $res->{'CTS'};
		$o->{'ATS'} = $res->{'ATS'};
		$o->{'SHCUT'} = $res->{'SHCUT'};
	}
	
	if($o->{'SHCUT'})
	{
		$res = $o->loadref($o->{'SHCUT'});
	}
	
	unless($o->access('r')){ $res = {}; }
	
	my $vt;
	for my $key (keys( %$p ))
	{
		if($key eq '|'){ next; }
		$vt = 'CMSBuilder::DBI::vtypes::'.$p->{$key}{'type'};
		
		if(${$vt.'::virtual'} || $p->{$key}{'virtual'}){ next }
		
		if(${$vt.'::filter'})
		{
			$o->{$key} = $vt->filter_load($key,$res->{$key},$o);
		}
		else
		{
			$o->{$key} = $res->{$key};
		}
		
		if(${$vt.'::property'})
		{
			tie($o->{$key},'CMSBuilder::Property',$o,$key);
		}
	}
}

sub save
{
	my $o = shift;
	my $p = $o->props();
	my @vals = ();
	my $val;
	
	unless($o->{'ID'}){ return; }
	unless($o->access('w')){ return; }
	if($o->{'ID'} =~ m/\D/){ CMSBuilder::IO::err500('DBO: Non-digital ID passed to save(), '.ref($o).', '.$o->{'ID'}); }
	
	#print 'Saving: ',$o->myurl(),'<br>';
	
	my $sql =
	'
	UPDATE '.$o->object_tblname().' SET
	SHCUT = ?
	';
	
	my $vt;
	for my $key (keys( %$p ))
	{
		if($key eq '|'){ next; }
		$vt = 'CMSBuilder::DBI::vtypes::'.$p->{$key}{'type'};
		
		if(${$vt.'::virtual'} || $p->{$key}{'virtual'}){ next }
		
		$sql .= ",\n `$key` = ? ";
		
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
	$str = $CMSBuilder::DBI::dbh->prepare($sql);
	$str->execute($o->{'SHCUT'},@vals,$o->{'ID'});
}

sub insert
{
	my $c = shift;
	
	my $id = $c->insertid();
	my $p = $c->props();
	my (@vals,$val,@flds,$sql);
	
	$sql = 'UPDATE '.$c->object_tblname().' SET ';
	
	my $vt;
	for my $key (keys( %$p ))
	{
		$vt = 'CMSBuilder::DBI::vtypes::'.$p->{$key}{'type'};
		
		if(${$vt.'::virtual'} || $p->{$key}{'virtual'}){ next; }
		unless(${$vt.'::filter'}){ next; }
		
		$val = $vt->filter_insert($key,$c);
		
		push @flds," $key = ? ";
		push @vals, $val;
	}
	
	$sql .= join(', ',@flds).' WHERE ID = ? LIMIT 1';
	
	if(@flds)
	{
		my $str = $CMSBuilder::DBI::dbh->prepare($sql);
		$str->execute(@vals,$id);
	}
	
	return $id;
}

sub insertid
{
	my $c = shift;
	my $str;
	
	$str = $CMSBuilder::DBI::dbh->prepare('INSERT INTO '.$c->object_tblname().' (OWNER,CTS) VALUES (?,NOW())');
	$str->execute($user->myurl);
	
	$str = $CMSBuilder::DBI::dbh->prepare('SELECT LAST_INSERT_ID() FROM '.$c->object_tblname().' LIMIT 1');
	$str->execute();
	
	my ($id) = $str->fetchrow_array();
	
	return $id;
}

sub loadref
{
	my $o = shift;
	my $id = shift;
	my $res;
	
	if($id =~ m/\D/){ CMSBuilder::IO::err500('DBO: Non-digital ID passed to loadref(), '.ref($o).', '.$id); }
	
	my $str = $CMSBuilder::DBI::dbh->prepare('SELECT * FROM '.$o->object_tblname().' WHERE ID = ? LIMIT 1');
	$str->execute($id);
	
	$res = $str->fetchrow_hashref(); #'NAME_lc'
	
	return $res;
}

sub ochown
{
	my $o = shift;
	my $uobj = shift;
	
	unless($uobj){ return 0; }
	unless($o->access('o')){ return 0; }
	
	$o->{'OWNER'} = $uobj->myurl;
	
	$CMSBuilder::DBI::dbh->do('UPDATE '.$o->object_tblname().' SET OWNER = ? WHERE ID = ?',undef,$o->{'OWNER'},$o->{'ID'});
	
	return $uobj;
}

sub papa_set
{
	my $o = shift;
	my $np = shift;
	
	my $papa = $o->papa();
	
	if(ref($np) && exists $np->{'ID'} && $np->{'ID'})
	{
		$o->{'PAPA_CLASS'} = ref($np);
		$o->{'PAPA_ID'} = $np->{'ID'};
	}
	else
	{
		$o->{'PAPA_CLASS'} = '';
		$o->{'PAPA_ID'} = 0;
	}
	
	$CMSBuilder::DBI::dbh->do
	(
		'UPDATE '.$o->object_tblname().' SET PAPA_ID = ?, PAPA_CLASS = ? WHERE ID = ? LIMIT 1',
		undef,
		$o->{'PAPA_ID'}, $o->{'PAPA_CLASS'}, $o->{'ID'}
	);
	
	return $papa;
}


###################################################################################################
# Вспомогательные методы работы с Базой Данных
###################################################################################################

sub check
{
	my $c = shift;
	
	my $p = $c->props();
	my @aview = $c->aview();
	
	my $i;
	for $i (0 .. $#aview)
	{
		unless($p->{$aview[$i]})
		{
			print STDERR "\n",'@'.$c.'->aview() contain prop ',$aview[$i],' not existed in props.',"\n";
			splice(@aview,$i,1)
		}
	}
	
	#print STDERR '[@'.$c.'->aview() checked]';
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
	delete $CMSBuilder::DBI::dbo_cache{ref($o).$o->{'ID'}};
	
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
	my $c = shift;
	
	return CMSBuilder::DBI::table_exists($c->object_tblname());
}

sub table_fix
{
	my $c = shift;
	my $test = shift;
	my($str,$r,%cols,$p,$vtype,$csql,$tbl);
	
	my %log;# = ('changed'=>[],'existed'=>[],'deleted'=>[]);
	
	# проверка на существование таблицы
	unless($c->table_have)
	{
		$c->table_cre();
		push @{$log{'existed'}}, {'name'=>'TABLE'};
		return \%log;
	}
	
	$tbl = $c->object_tblname();
	$p = $c->props();
	
	$str = $CMSBuilder::DBI::dbh->prepare('DESCRIBE '.$tbl);
	$str->execute();
	
	while($r = $str->fetchrow_arrayref() )
	{
		if($sys_cols{$r->[0]}){ next; }
		$cols{$r->[0]} = $r->[1];
		$cols{$r->[0]} =~ s/\s//g;
	}
	
	# проверка на изменение типа
	for my $cn (keys(%cols))
	{
		unless($p->{$cn}){ next; }
		$vtype = 'CMSBuilder::DBI::vtypes::'.$p->{$cn}{'type'};
		$csql = $vtype->table_cre($p->{$cn});
		$csql =~ s/\s//g;
		
		if(uc($cols{$cn}) ne uc($csql))
		{
			unless($test)
			{
				push @{$log{'changed'}}, {'name'=>$cn,'from'=>$cols{$cn},'to'=>$csql};
				$CMSBuilder::DBI::dbh->do('ALTER TABLE '.$tbl.' CHANGE `'.$cn.'` `'.$cn.'` '.$csql.' NOT NULL ');
			}
		}
	}
	
	# проверка на новые поля
	for my $cn (keys(%$p))
	{
		$vtype = 'CMSBuilder::DBI::vtypes::'.$p->{$cn}{'type'};
		$csql = $vtype->table_cre($p->{$cn});
		$csql =~ s/\s//g;
		
		unless($cols{$cn} || $p->{$cn}{'virtual'})
		{
			unless($test)
			{
				push @{$log{'existed'}}, {'name'=>$cn,'to'=>$csql};
				$CMSBuilder::DBI::dbh->do('ALTER TABLE '.$tbl.' ADD `'.$cn.'` '.$csql.' NOT NULL ');
			}
		}
	}
	
	# проверка на удалённые поля
	for my $cn (keys(%cols))
	{
		if(!$p->{$cn} || $p->{$cn}{'virtual'})
		{
			unless($test)
			{
				push @{$log{'deleted'}}, {'name'=>$cn,'from'=>$cols{$cn}};
				$CMSBuilder::DBI::dbh->do('ALTER TABLE '.$tbl.' DROP `'.$cn.'`');
			}
		}
	}
	
	return \%log;
}

sub table_cre
{
	my $c = shift;
	my($key,$p,$vtype,$sc);
	
	$p = $c->props();
	
	my $sql = 'CREATE TABLE IF NOT EXISTS '.$c->object_tblname().' ( '."\n";
	
	for $sc (sort keys %sys_cols)
	{
		$sql .= '`'.$sc.'` '.$sys_cols{$sc}.', '."\n";
	}
	
	for $key (keys %$p)
	{
		$vtype = 'CMSBuilder::DBI::vtypes::'.$p->{$key}{'type'};
		
		unless(${$vtype.'::virtual'} || $p->{$key}{'virtual'})
		{
			$sql .= " `$key` ".$vtype->table_cre($p->{$key}).' NOT NULL , '."\n";
		}
	}
	$sql =~ s/,\s*$//;
	$sql .= "\n )";
	
	my $str = $CMSBuilder::DBI::dbh->prepare($sql);
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