# имя класса (ака пакет perl)
package plgnFeedback;
use strict qw(subs vars);
our @ISA = ('CMSBuilder::Plugin');
use CMSBuilder;


#-------------------------------------------------------------------------------
sub plgn_load
{
   my $c = shift;
   cmsb_siteload('Feedback');
}

1;