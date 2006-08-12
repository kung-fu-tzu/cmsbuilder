# CMSBuilder © Леонов П. А., 2006

package CMSBuilder::MYURL;
use strict qw(subs vars);
use utf8;

use CMSBuilder;

sub process_request
{
	my $c = shift;
	my $r = shift;
	
	my $myurl = $r->{'_cmsb'}->{'path'};
	$myurl =~ s#\.html.*##g;
	$myurl = substr($myurl,1);
	$myurl =~ s#/#::#g;
	
	$myurl = $CMSBuilder::Config::slashobj_myurl if $r->{'_cmsb'}->{'path'} eq '/';
	
	my $obj = cmsb_url($myurl);
	
	return unless $obj;
	
	$r->{'main_obj'} = $obj;
	$obj->site_page($r);
	
	return 1;
}


1;