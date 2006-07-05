# (с) Леонов П.А., 2005

package CMSBuilder::DBI::vtypes::timestamp;
use strict qw(subs vars);
use utf8;

our @ISA = 'CMSBuilder::DBI::VType';
# Временная метка ####################################################

sub table_cre {'TIMESTAMP'}

1;