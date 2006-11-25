#!/usr/bin/perl
use strict;
use utf8;

use Test::Simple tests => 2;

use CMSBuilder::SysUtils qw(VIRTUAL);

{
	# проверим, работают ли варнинги в virtual
	
	local $CMSBuilder::SysUtils::virtual_warn_sub = sub {die};
	
	use warnings 'CMSBuilder::SysUtils';
	sub test::met1 {VIRTUAL}
	eval { test::met1() }; ok $@, 'VIRTUAL';
	
	no warnings 'CMSBuilder::SysUtils';
	sub test::met2 {VIRTUAL}
	eval { test::met2() }; ok !$@, 'VIRTUAL';
}

