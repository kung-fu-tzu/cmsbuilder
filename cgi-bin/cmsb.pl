#!/usr/bin/perl
use strict qw(subs vars);
#use warnings;

BEGIN
{
	require '/home/cmsbuilder2/cmsbuilder/Config.pm';
}

use CMSBuilder::Starter;
CMSBuilder::Starter->start();
