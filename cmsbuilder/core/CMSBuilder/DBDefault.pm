# CMSBuilder © Леонов П. А., 2005-2006

package CMSBuilder::DBDefault;
use strict;
use utf8;

our @ISA = qw(CMSBuilder::DB);

sub class_name {'Интерфейс к базам данных по умолчанию'}

#———————————————————————————————————————————————————————————————————————————————

my $dbobj;

sub connect			{$dbobj ||= $_[0]->_new();}
sub disconnect		{1}
sub fix_connection	{1}
sub upate_structure	{{}}

sub create			{1}
sub delete			{1}

sub save			{1}
sub load			{{}}

sub count			{1}
sub all_ids			{1}

sub save_sys		{1}

1;