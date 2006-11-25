#!/usr/bin/perl
use strict;
use utf8;
BEGIN {exit 254 unless eval {require DBD::mysql}}
use Test::Simple tests => 51;
use Data::Dump 'dump';

use CMSBuilder::Config;
use CMSBuilder::Config::XML;

use CMSBuilder;
use CMSBuilder::VTypes;


require 'config.xml';
require CBM::DBI::MySQL;



# проверим, подключается ли вообще
ok my $dbh = CBM::DBI::MySQL->connect qw(DBI:mysql:cmsbuilder_tests root pas), 'connecting to DBI:mysql:cmsbuilder_tests';

# возвращает наш дескриптор, а не DBI::db
ok $dbh->isa('CBM::DBI::MySQL'), 'isa CBM::DBI::MySQL';



#———————————————————————————————————————————————————————————————————————————————



# удалим таблицу, если есть
ok $dbh->dbi->do('DROP TABLE IF EXISTS `describe_test`');

# создадим таблицу через SQL
ok $dbh->dbi->do('CREATE TABLE `describe_test` (`a` VARCHAR(10), `b` INT(5) NOT NULL, `c` TIMESTAMP)');

# ... и немного протестируем mysql_describe
#warn dump $dbh->mysql_describe('describe_test');
ok my $desc1 = $dbh->mysql_describe('describe_test');
ok $desc1->{a}->{default} eq undef, 'a->default';
ok $desc1->{a}->{null} eq 'YES', 'a->null';
ok $desc1->{a}->{type} eq 'varchar(10)', 'a->type';

ok ! $desc1->{b}->{default}, 'b->default';
ok $desc1->{b}->{null} =~ /^(NO)?$/i, 'b->null';
ok $desc1->{b}->{type} eq 'int(5)', 'b->type';

ok $desc1->{c}->{default} eq 'CURRENT_TIMESTAMP', 'b->cefault';
ok $desc1->{b}->{null} =~ /^(NO|YES|)$/i, 'c->null';
ok $desc1->{c}->{type} eq 'timestamp', 'c->type';



#———————————————————————————————————————————————————————————————————————————————



# неизвестные типы запросов вызывают исключение
eval { $dbh->structure('something strange', 'class') }; ok $@, 'unknown action type';
eval { $dbh->structure('something strange') }; ok $@, 'structure prototype';



#———————————————————————————————————————————————————————————————————————————————



attributes 'Test::First',
{
	name	=> string (length => 17),
	hide	=> bool,
	href	=> string,
	owner	=> string,
	code	=> bool
};


# возможно, удаляем таблицу
$dbh->structure('drop', 'Test::First');
# здесь не удаляем
ok ! $dbh->structure('drop', 'Test::First')->{dropped};
ok $dbh->structure('update', 'Test::First', Test::First->attrs)->{existed}, 'structure create';
ok $dbh->structure('drop', 'Test::First')->{dropped}, 'structure drop';
ok $dbh->structure('update', 'Test::First', Test::First->attrs)->{existed}, 'structure create 2';



# бегло проверим состав таблицы
ok my $attrs_str = join(' ', sort keys %{Test::First->attrs}, keys %{CBM::DBI::MySQL->sys_attrs});
ok join(' ', sort keys %{ $dbh->mysql_describe('Test::First') }) eq $attrs_str, 'mysql_describe after update';


#warn dump $dbh->mysql_describe('Test::First');
#warn dump $dbh->structure('drop', 'Test::First');

attributes 'Test::First',
{
	name	=> string (length => 27, default => 'Без имени'),
	show	=> bool,
	href	=> string,
	owner	=> string,
	code	=> bool
};

my $res = $dbh->structure('update', 'Test::First', Test::First->attrs);

ok $res->{deleted}->{hide}->{from} eq 'tinyint(1)';
ok $res->{added}->{show}->{to} eq 'tinyint(1)';
ok $res->{updated}->{name}->{from} eq 'varchar(17)' && $res->{updated}->{name}->{to} eq 'varchar(27)';



#———————————————————————————————————————————————————————————————————————————————



ok $dbh->create('Test::First', Test::First->attrs, {}), 'create';
ok $dbh->create('Test::First', Test::First->attrs, {name => 'Вася', owner => 'Users::User1'}), 'create';



#———————————————————————————————————————————————————————————————————————————————



ok $dbh->load('Test::First', Test::First->attrs, 1), 'load';
ok $dbh->load('Test::First', Test::First->attrs, 2), 'load';
ok ! $dbh->load('Test::First', Test::First->attrs, 20), 'load';
ok my $dres = $dbh->load('Test::First', Test::First->attrs, 2), 'load';

ok $dres->{owner} eq 'Users::User1';
ok $dres->{name} eq 'Вася';



#———————————————————————————————————————————————————————————————————————————————



ok $dbh->save('Test::First', Test::First->attrs, {name => 'Миша'}, 2), 'save';
ok $dres = $dbh->load('Test::First', Test::First->attrs, 2), 'load';
ok $dres->{name} eq 'Миша';



#———————————————————————————————————————————————————————————————————————————————



ok $dbh->count('Test::First') == 2, 'count';
ok join ' ', $dbh->nums('Test::First') eq '1 2', 'nums';


#———————————————————————————————————————————————————————————————————————————————



ok $dbh->delete('Test::First', 1), 'delete';
ok ! $dbh->delete('Test::First', 1), 'delete';
ok ! $dbh->load('Test::First', Test::First->attrs, 1), 'load';
ok $dbh->load('Test::First', Test::First->attrs, 2), 'load';



#———————————————————————————————————————————————————————————————————————————————



ok ! $dbh->fix;
ok $dbh->dbi->disconnect;
ok $dbh->fix;

ok $dbh->load('Test::First', Test::First->attrs, 2), 'load';
ok join ' ', $dbh->nums('Test::First') eq '2', 'nums';


#———————————————————————————————————————————————————————————————————————————————

ok $dbh->connected;
ok $dbh->disconnect;
ok ! $dbh->disconnect;
ok ! $dbh->connected;



#———————————————————————————————————————————————————————————————————————————————



$dbh->select('');



#———————————————————————————————————————————————————————————————————————————————

