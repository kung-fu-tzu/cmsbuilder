# (с) Леонов П.А., 2005

package plgnNews;
use strict qw(subs vars);
our @ISA = ('CMSBuilder::Plugin');

use CMSBuilder;

sub plgn_load
{
	cmsb_siteload('News');
}


1;