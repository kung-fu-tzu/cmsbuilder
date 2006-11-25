#!/usr/bin/perl
use strict;
use utf8;

use Test::Simple tests => 15;

use CMSBuilder;

use CMSBuilder::Config '$cfg';
use CMSBuilder::Config::XML;

#———————————————————————————————————————————————————————————————————————————————


# тестим XML
eval { require 'not-existed-config.xml' }; ok $@;

require 't/CMSBuilder/Config/test1.xml';

ok $cfg->{db};
ok $cfg->{db}->{mysql};
ok $cfg->{db}->{mysql}->{base} eq 'cmsbuilder';
ok $cfg->{db}->{mysql}->{user} eq 'root';
ok $cfg->{db}->{mysql}->{password} eq 'pas';
ok $cfg->{db}->{mysql}->{source} eq 'DBI:mysql:cmsbuilder;host=localhost;port=3306';


require 't/CMSBuilder/Config/test2.xml';

ok $cfg->{db};
ok $cfg->{db}->{mysql};
ok $cfg->{db}->{mysql}->{base} eq 'cmsbuilder';
ok $cfg->{db}->{mysql}->{base2_full} eq 'cmsbuilder-test2-full';
ok $cfg->{db}->{mysql}->{base2} eq 'cmsbuilder-test2';
ok $cfg->{db}->{mysql}->{user} eq 'vasia';
ok $cfg->{db}->{mysql}->{password} eq 'vasia-secret';
ok $cfg->{db}->{mysql}->{source} eq 'DBI:mysql:cmsbuilder;host=testhost;port=3306';


1;