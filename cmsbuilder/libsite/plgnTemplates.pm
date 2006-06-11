# (с) Леонов П.А., 2006

package plgnTemplates;
use strict qw(subs vars);
our @ISA = ('CMSBuilder::Plugin');

use CMSBuilder;


sub plgn_load
{
	my $c = shift;
	
	cmsb_siteload('Templates');
}


1;
