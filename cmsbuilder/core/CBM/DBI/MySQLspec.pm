# CMSBuilder © Леонов П. А., 2005-2006

package CBM::DBI::MySQLspec;
use strict;
use utf8;

use Carp ();
use CMSBuilder::Config '$cfg';
use CMSBuilder::VTypes;



system_attributes
{
	'sys:num'		=> mysql_num (system => 1),
	'sys:cts'		=> datetime (system => 1),
	'sys:ats'		=> datetime (system => 1),
	'sys:owner'		=> string (system => 1),
	'sys:parent'	=> string (system => 1)
};


sub dbi {$_[0]->{dbi}}

sub mysql_describe
{
	my $o = shift;
	my $cn = shift;
	
	my $tbl = $o->mysql_class_tblname($cn);
	
	my $desc = $o->dbi->selectall_arrayref('DESCRIBE ' . $tbl);
	
	my $res;
	my @cns = qw(type null key default extra);
	
	map { my $n; $res->{$$_[0]} = { map { $cns[$n++ - 1] => $_ } @$_ } } @$desc;
	
	return $res;
}

sub mysql_class_tblname
{
	my $o = shift;
	my $cn = shift;
	
	$cn =~ s/::/-/g;
	
	return '`' . $cfg->{db}->{table_prefix} . $cn . '`';
}

sub mysql_childs_tblname
{
	my $o = shift;
	my $cn = shift;
	
	$cn =~ s/::/-/g;
	
	return '`' . $cfg->{db}->{table_prefix} . $cn . '_childs`';
}

sub mysql_table_exists
{
	my $o = shift;
	my $tn = shift;
	return unless $tn;
	
	my $sql;
	
	
	$tn =~ m/`(.+)`(?:\.`(.+)`)?/;
	
	if ($1 && $2)
	{
		$sql = "SHOW TABLES FROM `$1` LIKE '$2'";
	}
	elsif ($1)
	{
		$sql = "SHOW TABLES LIKE '$1'";
	}
	
	Carp::croak "mysql_table_exists with strange table name: '$tn'" unless $sql;
	
	return $o->dbi->selectrow_array($sql);
}


=com




sub fix_connection
{
	my $o = shift;
	
	eval # типа try
	{
		$o->do('SELECT NOW()');
	};
	if($@) # типа catch
	{
		warn 'DBI reconnecting...' if $^W;
		$o->connect();
		warn 'DBI reconnected OK.' if $^W;
	}
}


sub mysql_sel_one
{
	my $c = shift;
	my $wh = shift;
	
	my $str = $dbh->prepare('SELECT ID FROM '.mysql_object_tblname($c).' WHERE '.$wh.' LIMIT 1');
	$str->execute(@_);
	
	my ($id) = $str->fetchrow_array();
	
	if(!$id){ return undef; }
	
	return $c->load($id);
}

sub mysql_sel_where
{
	my $c = shift;
	my $wh = shift;

	my($id,@oar);

	my $str = $dbh->prepare('SELECT ID FROM '.db_mysql_object_tblname($c).' WHERE '.$wh);
	$str->execute(@_);
	
	while( ($id) = $str->fetchrow_array() )
	{
		push @oar,$c->load($id);
	}
	
	return @oar;
}

sub mysql_sel_sql
{
	my $c = shift;
	my $sql = shift;
	
	my $res;
	my @oar;
	
	my $str = $dbh->prepare($sql);
	$str->execute(@_);
	
	while( $res = $str->fetchrow_hashref('NAME_lc') ){ push(@oar,$c->load($res->id)) }
	
	return @oar;
}



#—————————————————————————————— Дополнительные функции —————————————————————————



=cut

1;