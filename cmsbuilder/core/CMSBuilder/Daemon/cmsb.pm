# (с) Леонов П.А., 2005

package CMSBuilder::Daemon::cmsb;
use strict;
use utf8;

use base 'CMSBuilder::Daemon::cgi';


sub daemon_load
{
	my $c = shift;
	
	require CMSBuilder;
	CMSBuilder->load;
}


sub daemon_unload
{
	my $c = shift;
	
	CMSBuilder->unload;
}


sub daemon_job
{
	CMSBuilder->process;
}



1;