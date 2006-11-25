# CMSBuilder © Леонов П. А., 2005-2006

package modDBI::SDBM;
use strict;
use utf8;

our @ISA = qw(CMSBuilder::DB CMSBuilder::Module);

sub class_name {'Интерфейс к базе SDBM'}

use CMSBuilder::Config;

#use SDBM_File; tie %h, q(SDBM_File), q(/tmp/a), undef, 640


1;