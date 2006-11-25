#!/usr/bin/perl
use strict;
use utf8;

use Test::Simple tests => 14;

BEGIN
{
	# если сделать use CMSBuilder::DB, то появится &CMSBuilder::DB::import
	require CMSBuilder::DB;
}

# этот файл тестирует только набор "виртуальных" методов

BEGIN
{
	### протестим состав членов класса, он должен быть точно таким как в массиве
	my @def_funcs = qw
	(
		_perl_new
		class_name
		
		structure
		
		connect disconnect connected fix
		
		create delete save load select
		
		count nums
	);
	
	# upate_structure
	
	### выясняем разницу между известными функциями и сущ. в классе
	my %res = map {$_ => 'ADDED'} grep { uc $_ ne $_ } keys %CMSBuilder::DB::;
	map { exists $res{$_} ? delete $res{$_} : ($res{$_} = 'DELETED') } @def_funcs;
	
	### проверяем есть ли разница, и, если есть, то выводим ее
	my $diff = join(', ', map {"$_: $res{$_}"} keys %res);
	ok !$diff, $diff || 'methods';
}


#die join ' ', keys %CMSBuilder::DB::;

my $dbh = CMSBuilder::DB->_perl_new;
ok ref $dbh eq 'CMSBuilder::DB', '_perl_new';



use warnings 'CMSBuilder::DB';

ok ! $dbh->connect, 'connect';
ok ! $dbh->disconnect, 'disconnect';
ok ! $dbh->connected, 'connected';
ok ! $dbh->fix, 'fix';
ok ! $dbh->structure, 'structure';
ok ! $dbh->create, 'create';
ok ! $dbh->delete, 'delete';
ok ! $dbh->save, 'save';
ok ! $dbh->load, 'load';
ok ! $dbh->select, 'select';
ok ! $dbh->count, 'count';
ok ! $dbh->nums, 'nums';
