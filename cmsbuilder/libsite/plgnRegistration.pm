# имя класса (ака пакет perl)
package plgnRegistration;
use strict qw(subs vars);
our @ISA = ('CMSBuilder::Plugin');

#-------------------------------------------------------------------------------

sub plgn_load
{
   my $c = shift;
   CMSBuilder::cmsb_siteload('Registration');
}

1;