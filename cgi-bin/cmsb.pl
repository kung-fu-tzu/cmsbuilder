#!/usr/bin/perl
use strict qw(subs vars);
#use warnings;

BEGIN
{
	require '/home/cmsbuilder3/cmsbuilder/Config.pm';
}

use CMSBuilder::Starter;
CMSBuilder::Starter->start();
