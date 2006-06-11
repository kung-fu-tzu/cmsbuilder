# имя класса (ака пакет perl)
package plgnForms;
use strict qw(subs vars);
our @ISA = ('CMSBuilder::Plugin');
use CMSBuilder;


#-------------------------------------------------------------------------------
sub plgn_load
{
   my $c = shift;
   cmsb_siteload('Forms');
}

1;