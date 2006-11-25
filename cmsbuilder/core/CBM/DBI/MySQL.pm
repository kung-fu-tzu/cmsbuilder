# CMSBuilder © Леонов П. А., 2005-2006

package CBM::DBI::MySQL;
use strict;
use utf8;

use base qw(CBM::DBI::MySQLspec CMSBuilder::DB CMSBuilder::Module);

sub class_name {'Интерфейс к MySQL'}

use CBM::DBI::MySQLspec;

use DBI;
use Carp ();

use CMSBuilder::Config qw(db.mysql);
use CMSBuilder::Utils;


#———————————————————————————————————————————————————————————————————————————————



sub create
{
	my $o = shift;
	my $cn = shift;
	
	my $attrs = { %{shift()}, %{$o->sys_attrs}};
	my $vals = shift;
	
	my @flds;
	my @vals;
	
	for my $p (keys %$attrs)
	{
		push @flds, "`$p`";
		push @vals, $vals->{$p} || $attrs->{$p}->default;
	}
	
	my $tbl = $o->mysql_class_tblname($cn);
	
	my $sql = 'INSERT INTO ' . $tbl . ' (' . join(', ', @flds) . ') VALUES (' . join(', ', ('?') x scalar @flds) . ')';
	
	$o->dbi->prepare($sql)->execute(@vals) || return undef;
	my ($num) = $o->dbi->selectrow_array('SELECT LAST_INSERT_ID() FROM ' . $tbl);
	
	return $num;
}


sub load
{
	my $o = shift;
	my $cn = shift;
	my $attrs = { %{shift()}, %{$o->sys_attrs} };
	my $num = shift;
	
	my @flds;
	
	for my $p (keys %$attrs)
	{
		push @flds, "`$p`";
	}
	
	my $tbl = $o->mysql_class_tblname($cn);
	my $sql = 'SELECT ' . join(', ', @flds) . ' FROM ' . $tbl . ' WHERE `sys:num` = ? LIMIT 1';
	
	my ($data) = $o->dbi->selectrow_hashref($sql, undef, $num);
	return undef unless $data;
	$data = decode_utf8_hashref $data;
	
	#warn Data::Dump::dump $data;
	
	my $res;
	
	for my $p (keys %$attrs)
	{
		$res->{$p} = $attrs->{$p}->mysql_load( $data->{$p}, @_ );
	}
	
	return $res;
}

sub select($)
{
	my $o = shift;
	my $cn = shift;
	
}

sub save
{
	my $o = shift;
	my $cn = shift;
	my $attrs = { %{shift()}, %{$o->sys_attrs} };
	my $vals = shift;
	my $num = shift;
	
	$vals->{'sys:num'} = $num;
	
	my @flds;
	my @vals;
	
	for my $p (keys %$attrs)
	{
		push @flds, "`$p`";
		push @vals, $vals->{$p};
	}
	
	my $tbl = $o->mysql_class_tblname($cn);
	my $sql = 'UPDATE ' . $tbl . ' SET ' . join(', ', map {"$_ = ?"} @flds) . ' WHERE `sys:num` = ? LIMIT 1';
	
	return $o->dbi->do($sql, undef, @vals, $num) ? 1 : 0;
}


sub delete
{
	my $o = shift;
	my $cn = shift;
	my $num = shift;
	
	my $tbl = $o->mysql_class_tblname($cn);
	my $sql = 'DELETE FROM ' . $tbl . ' WHERE `sys:num` = ? LIMIT 1';
	
	return $o->dbi->do($sql, undef, $num) > 0 ? 1 : 0;
}


sub count
{
	my $o = shift;
	my $cn = shift;
	
	my ($count) = $o->dbi->selectrow_array('SELECT COUNT(`sys:num`) FROM ' . $o->mysql_class_tblname($cn));
	
	return $count;
}


sub nums
{
	my $o = shift;
	my $cn = shift;
	
	my $all = $o->dbi->selectall_arrayref('SELECT `sys:num` FROM ' . $o->mysql_class_tblname($cn));
	
	return map {$_->[0]} @$all;
}


sub connect
{
	my $c = shift;
	
	my $o = ref($c) ? $c : $c->_perl_new;
	
	my $dbi = DBI->connect(@_) || Carp::croak "Cant connect to $_[0]: $!";
	
	$o->{connect_parameters} = [@_];
	
	$dbi->{InactiveDestroy} = $mysql_inactive_destroy;
	
	if ($mysql_charset)
	{
		$dbi->do("SET character_set_client='$mysql_charset'");
		$dbi->do("SET character_set_results='$mysql_charset'");
	}
	
	if ($mysql_colcon)
	{
		$dbi->do("SET collation_connection='$mysql_colcon'");
	}
	
	$dbi->{HandleError} = sub { local $Carp::CarpLevel = 1; Carp::croak($_[0]);	};
	$dbi->{RaiseError} = 1;
	
	$o->{dbi} = $dbi;
	
	return $o
}

sub fix
{
	my $o = shift;
	
	unless ($o->connected)
	{
		my @prms = @{ $o->{connect_parameters} };
		$o->connect(@{ $o->{connect_parameters} });
		Carp::carp 'DBI reconnected';
		
		return 1;
	}
	else
	{
		return;
	}
}

sub connected
{
	my $o = shift;
	
	#eval
	#{
	#	$o->dbi->do('SELECT NOW()');
	#};
	#
	#return !$@;
	
	return $o->dbi->ping;
}

sub disconnect
{
	my $o = shift;
	
	return unless $o->connected;
	
	return $o->dbi->disconnect;
}

sub structure($$;@)
{
	my $o = shift;
	my $act = shift;
	my $cn = shift;
	
	my $prms; # тут, потому что в конце: ... @do unless $prms->{test}
	my @do;
	my %log;
	
	# Именовынные параметры получаем позже потому, что есть два варианта вызова:
	# ...->structure('update', class, props, syss [, named => params])
	# и
	# ...->structure('drop', class [, named => params])
	# в первом случае именованные параметры начинаются с 5, а во втором — с 3.
	
	my $tbl = $o->mysql_class_tblname($cn);
	
	if ($act eq 'drop')
	{
		if ( $o->mysql_table_exists($tbl) )
		{
			# таблица есть
			my $sql = 'DROP TABLE IF EXISTS ' . $tbl;
			
			$log{dropped}->{$cn} = {sql => $sql};
			push @do, $sql;
		}
	}
	
	elsif ($act eq 'update')
	{
		my $props = shift;
		$prms = {@_};
		
		die 'Has no two hashref in props and syss' unless ref($props) eq 'HASH';
		
		my $all = {%$props, %{$o->sys_attrs}};
		
		# проверка существования таблицы
		if ( $o->mysql_table_exists($tbl) )
		{
			# узнаем текущую структуру таблицы
			my $str = $o->dbi->prepare('DESCRIBE ' . $tbl);
			$str->execute;
			
			my %cols;
			
			while (my $r = $str->fetchrow_arrayref)
			{
				$cols{$r->[0]} = $r->[1];
			}
			
			no strict 'refs';
			
			# проверка на изменение типа
			for my $cn (keys %cols)
			{
				next unless $all->{$cn};
				
				my $csql = $all->{$cn}->mysql_field_add;
				my $nsql = $all->{$cn}->mysql_field_check;
				
				if (lc $cols{$cn} ne lc $nsql)
				{
					#warn $cols{$cn} . ' => ' . $nsql;
					$log{updated}->{$cn} = { from => $cols{$cn}, to => $csql };
					push @do, 'ALTER TABLE ' . $tbl . ' CHANGE `' . $cn . '` `' . $cn . '` ' . $csql;
				}
			}
			
			# проверка на новые поля
			for my $cn (keys %$all)
			{
				#next if ${$vt . '::virtual'} || $p->{$cn}{'virtual'};
				
				my $csql = $all->{$cn}->mysql_field_add;
				
				unless ($cols{$cn})
				{
					$log{added}->{$cn} = {to => $csql};
					push @do, 'ALTER TABLE ' . $tbl . ' ADD `' . $cn . '` ' . $csql;
				}
			}
			
			# проверка на удаленные поля
			for my $cn (keys %cols)
			{
				unless ($all->{$cn})
				{
					$log{deleted}->{$cn} = {from => $cols{$cn}};
					push @do, 'ALTER TABLE ' . $tbl . ' DROP `' . $cn . '`';
				}
			}
		}
		else
		{
			# таблица не существует
			
			my @flds;
			
			for my $key (sort keys %$all)
			{
				push @flds, " `$key` " . $all->{$key}->mysql_field_add;# . " NOT NULL";
			}
			
			my $sql = 'CREATE TABLE IF NOT EXISTS ' . $tbl . ' (' . join(',', @flds) . ')';
			
			$log{existed}->{$cn} = {sql => $sql};
			push @do, $sql;
		}
	}
	else
	{
		Carp::croak 'Unknown action type passed: "' . $act . '"';
	}
	
	map { $o->dbi->do($_) }  @do unless $prms->{test};
	
	return \%log;
}


1;