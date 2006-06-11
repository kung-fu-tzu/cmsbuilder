# (с) Леонов П.А., 2005

package plgnCatalog;
use strict qw(subs vars);
our @ISA = ('CMSBuilder::Plugin');

use CMSBuilder;

#-------------------------------------------------------------------------------


sub plgn_load
{
	my $c = shift;
	
	cmsb_siteload('Catalog');
}


1;