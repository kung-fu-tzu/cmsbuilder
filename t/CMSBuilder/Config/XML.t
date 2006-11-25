#!/usr/bin/perl
use strict;
use utf8;

use Test::Simple tests => 22;
use Data::Dump qw(dump);

use CMSBuilder::Config;
use CMSBuilder::Config::XML;

my $xml_cnf = q
(
<config>
	<db
	table_prefix="cb_"
	user="{/config/db/mysql/@user}"
	user2="{/config/db/mysql/@user2}"
	>
		<mysql
		class="modDBI::MySQL"
		base="cmsbuilder"
		user="root"
		user2="{/config/db/mysql/@user}"
		password="pas"
		port="3306"
		source="DBI:mysql:cmsbuilder;host={/config/db/mysql/@host};port={/config/db/mysql/@port}"
		host="localhost"
		/>
	</db>
	<val>123
	456</val>
	<test
	val="{../val}"
	/>
	<r1><r2><r3><r4 var="val"/></r3></r2></r1>
	<cont>1<a/>2<b/>3<c/>4</cont>
</config>
);


ok my $dom = CMSBuilder::Config::XML->new->parse($xml_cnf);
ok $dom->isa('XML::DOM::Document');

my $cfg; # передадим неопределенный $cfg
eval { CMSBuilder::Config::XML::cmsb_make($dom->getDocumentElement, $cfg) }; ok $@;
$cfg = {};
ok CMSBuilder::Config::XML::cmsb_make($dom->getDocumentElement, $cfg);

#dump $cfg;

# никаких #text
ok ! exists $cfg->{'#text'}, '#text';

# содержимое должен уметь аккомулировать
ok $cfg->{cont}->{content} eq '1234', 'content';

ok $cfg->{r1}->{r2}->{r3}->{r4}->{var} eq 'val';

ok $cfg->{db}->{user} eq "root", 'from subtree';
ok $cfg->{db}->{user2} eq "root", 'from from subtree';

#die $cfg->{db}->{test};

ok $cfg->{db}->{table_prefix} eq "cb_";
ok $cfg->{db}->{mysql}->{port} == 3306;
ok $cfg->{db}->{mysql}->{host} eq 'localhost';
ok $cfg->{db}->{mysql}->{source} eq 'DBI:mysql:cmsbuilder;host=' . $cfg->{db}->{mysql}->{host} . ';port=' . $cfg->{db}->{mysql}->{port};

ok $cfg->{val}->{content} eq "123\n\t456";
ok $cfg->{test}->{val} eq $cfg->{val}->{content};


#dump $cfg;
#die;

# попробуем загрузить конфиг из файла
my $cfg1 = {};
ok my $dom1 = CMSBuilder::Config::XML->new->parsefile('t/CMSBuilder/Config/test1.xml');
ok CMSBuilder::Config::XML::cmsb_make($dom1->getDocumentElement, $cfg1), 'fromfile';
ok $cfg1->{db}->{mysql}->{user} eq 'root';


# нельзя создавать повторяющиеся теги (свойства тоже, но это уже на совести парсера)
ok my $dom2 = CMSBuilder::Config::XML->new->parse('<c><r><a/><a/></r></c>');
eval { CMSBuilder::Config::XML::cmsb_make($dom2->getDocumentElement, {}) }; ok $@, 'multiple in XML';

ok my $dom3 = CMSBuilder::Config::XML->new->parse('<c><m/><r><m/><b var="{//m}"/></r></c>');
eval { CMSBuilder::Config::XML::cmsb_make($dom3->getDocumentElement, {}) }; ok $@, 'multiple in XPath';

#———————————————————————————————————————————————————————————————————————————————


1;