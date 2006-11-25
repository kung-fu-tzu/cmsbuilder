#!/usr/bin/perl
use strict;
#use warnings;

BEGIN
{
	$CMSBuilder::Config::path_home = '/home/cmsbuilder3';
	require $CMSBuilder::Config::path_home . '/cmsbuilder/Config.local.pm';
}

use CMSBuilder::Starter;
CMSBuilder::Starter->start();
