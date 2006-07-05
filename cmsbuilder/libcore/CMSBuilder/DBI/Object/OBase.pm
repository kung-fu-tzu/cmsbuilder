# (с) Леонов П.А., 2005

package CMSBuilder::DBI::Object::OBase;
use strict qw(subs vars);
use utf8;

use Carp;
use plgnUsers;
use CMSBuilder::IO;
use CMSBuilder::Utils;

#————————————————————————————————— Системные поля ——————————————————————————————

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


#——————————————————— Следующие методы находятся в разработке ———————————————————

sub object_tblname
{
	my $tn = '`dbo_'.( ref($_[0]) || $_[0] ).'`';
	$tn =~ s/\:\:/\_/g;
	return $tn;
}


#—————————————————————— Методы выполняющие поиск объектов ——————————————————————

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


#—————————————————————— Методы для непосредственной работы с Базой Данных —————————————————————————

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
	if($o->{'ID'} =~ m/\D/){ err500('DBO: Non-digital ID passed to del(), '.ref($o).', '.$o->{'ID'}); }
	
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
		$res = decode_utf8_hashref($o->loadref($o->{'ID'}));
		
		if($res->{'ID'} != $o->{'ID'})
		{
			carp 'DBO: Loading from not existed row, class = "'.ref($o).'",ID = '.$o->{'ID'}."\n";
			if($CMSBuilder::Config::lfnexrow_error500){ err404('DBO: non existed row error'); }
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
		$vt = 'CMSBuilder::DBI::vtypes::'.$p->{$key}{'type'};
		
		if(${$vt.'::filter'})
		{
			$res->{$key} = $vt->filter_load($key,$res->{$key},$o);
		}
		
		if(${$vt.'::property'})
		{
			$o->{$key.'_real'} = $res->{$key};
			tie($o->{$key},'CMSBuilder::Property',$o,$key);
		}
		else
		{
			$o->{$key} = $res->{$key};
		}
	}
	
	$o->save if delete $o->{'_save_after_reload'};
}

sub save
{
	my $o = shift;
	my $p = $o->props();
	
	return unless $o->{'ID'};
	unless($o->access('w')){ return; }
	if($o->{'ID'} =~ m/\D/){ err500('DBO: Non-digital ID passed to save(), '.ref($o).', '.$o->{'ID'}); }
	
	#print 'Saving: ',$o->myurl(),'<br>';
	
	my($vt,$val,@flds,@vals);
	for my $key (keys( %$p ))
	{
		$vt = 'CMSBuilder::DBI::vtypes::'.$p->{$key}{'type'};
		
		if(${$vt.'::property'})
		{
			$val = $o->{$key.'_real'};
		}
		else
		{
			$val = $o->{$key};
		}
		
		if(${$vt.'::filter'})
		{
			$val = $vt->filter_save($key,$val,$o);
		}
		
		next if ${$vt.'::virtual'} || $p->{$key}{'virtual'};
		
		push @flds, "`$key` = ?";
		push @vals, $val;
	}
	
	my $sql = 'UPDATE '.$o->object_tblname().' SET `SHCUT` = ?, ' . join(',',@flds) . ' WHERE `ID` = ? LIMIT 1';
	
	my $str = $CMSBuilder::DBI::dbh->prepare($sql);
	$str->execute($o->{'SHCUT'},@vals,$o->{'ID'});
}

sub insert
{
	my $c = shift;
	my (@vals,@flds);
	
	my $id = $c->insertid();
	my $p = $c->props();
	
	my ($val,$vt);
	for my $key (keys( %$p ))
	{
		$vt = 'CMSBuilder::DBI::vtypes::' . $p->{$key}{'type'};
		
		next unless ${$vt.'::filter'};
		$val = $vt->filter_insert($key,$c);
		
		next if ${$vt.'::virtual'} || $p->{$key}{'virtual'};
		push @flds, "`$key` = ?";
		push @vals, $val;
	}
	
	my $sql = 'UPDATE ' . $c->object_tblname() . ' SET ' . join(', ',@flds) . ' WHERE ID = ? LIMIT 1';
	
	if(@flds)
	{
		$CMSBuilder::DBI::dbh->prepare($sql)->execute(@vals,$id);
	}
	
	return $id;
}

sub insertid
{
	my $c = shift;
	
	my $owner = $user ? $user->myurl : $CMSBuilder::Config::user_admin;
	$CMSBuilder::DBI::dbh->do('INSERT INTO '.$c->object_tblname().' (OWNER,CTS) VALUES (?,NOW())',undef,$owner);
	
	my $str = $CMSBuilder::DBI::dbh->prepare('SELECT LAST_INSERT_ID() FROM '.$c->object_tblname().' LIMIT 1');
	$str->execute();
	
	return $str->fetchrow_array();
}

sub loadref
{
	my $o = shift;
	my $id = shift;
	my $res;
	
	if($id =~ m/\D/){ err500('DBO: Non-digital ID passed to loadref(), '.ref($o).', '.$id); }
	
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


#—————————————————————— Вспомогательные методы работы с БД —————————————————————

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
	my($r,%cols,$p,$vt,$csql,$tbl,@do);
	
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
	
	my $str = $CMSBuilder::DBI::dbh->prepare('DESCRIBE '.$tbl);
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
		next unless $p->{$cn};
		$vt = 'CMSBuilder::DBI::vtypes::'.$p->{$cn}{'type'};
		$csql = $vt->table_cre($p->{$cn});
		$csql =~ s/\s//g;
		
		if(lc($cols{$cn}) ne lc($csql))
		{
			push @{$log{'changed'}}, {'name'=>$cn,'from'=>$cols{$cn},'to'=>$csql};
			push @do, 'ALTER TABLE '.$tbl.' CHANGE `'.$cn.'` `'.$cn.'` '.$csql.' NOT NULL';
		}
	}
	
	# проверка на новые поля
	for my $cn (keys(%$p))
	{
		$vt = 'CMSBuilder::DBI::vtypes::'.$p->{$cn}{'type'};
		next if ${$vt.'::virtual'} || $p->{$cn}{'virtual'};
		
		$csql = $vt->table_cre($p->{$cn});
		$csql =~ s/\s//g;
		
		unless($cols{$cn})
		{
			push @{$log{'existed'}}, {'name'=>$cn,'to'=>$csql};
			push @do, 'ALTER TABLE '.$tbl.' ADD `'.$cn.'` '.$csql.' NOT NULL';
		}
	}
	
	# проверка на удалённые поля
	for my $cn (keys(%cols))
	{
		$vt = 'CMSBuilder::DBI::vtypes::'.$p->{$cn}{'type'};
		
		if(!$p->{$cn} || ${$vt.'::virtual'} || $p->{$cn}{'virtual'})
		{
			push @{$log{'deleted'}}, {'name'=>$cn,'from'=>$cols{$cn}};
			push @do, 'ALTER TABLE '.$tbl.' DROP `'.$cn.'`';
		}
	}
	
	map { $CMSBuilder::DBI::dbh->do($_) } @do unless $test;
	
	return \%log;
}

sub table_cre
{
	my $c = shift;
	my (@flds);
	my $p = $c->props();
	
	for my $key (sort keys %sys_cols)
	{
		push @flds, "`$key` $sys_cols{$key}";
	}
	
	my $vt;
	for my $key (keys %$p)
	{
		$vt = 'CMSBuilder::DBI::vtypes::'.$p->{$key}{'type'};
		next if ${$vt.'::virtual'};
		
		push @flds, " `$key` ".$vt->table_cre($p->{$key})." NOT NULL";
	}
	
	my $sql = 'CREATE TABLE IF NOT EXISTS '.$c->object_tblname().' ( '.join(',',@flds).' )';
	
	if($CMSBuilder::DBI::dbh->prepare($sql)->execute())
	{
		return $sql;
	}
	else
	{
		return;
	}
}

1;