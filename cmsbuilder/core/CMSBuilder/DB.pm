# CMSBuilder © Леонов П. А., 2005-2006

package CMSBuilder::DB;
use strict;
use utf8;

use warnings::register;
use CMSBuilder::SysUtils qw(VIRTUAL);

sub class_name			{'Абстрактный интерфейс к базам данных'}

#———————————————————————————————————————————————————————————————————————————————

sub _perl_new			{ my $c = shift; return bless {@_}, $c }

sub connect				{VIRTUAL}
sub disconnect			{VIRTUAL}
sub connected			{VIRTUAL}
sub fix					{VIRTUAL}

sub structure			{VIRTUAL}

sub create				{VIRTUAL}
sub delete				{VIRTUAL}

sub save				{VIRTUAL}
sub load				{VIRTUAL}
sub select				{VIRTUAL}

sub count				{VIRTUAL}
sub nums				{VIRTUAL}


1;