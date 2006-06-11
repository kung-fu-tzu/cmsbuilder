# (с) Леонов П.А., 2006

package plgnSite;
use strict qw(subs vars);
our @ISA = ('CMSBuilder::Plugin');

use CMSBuilder;

sub main
{
	return modSite->new(1);
}



sub plgn_load
{
	my $c = shift;
	
	cmsb_siteload('Site');
	
	cmsb_event_reg('admin_view_additional',\&admin_additional);
	
	#unshift(@CMSBuilder::DBI::Object::ISA,'plgnSite::ObjectHook');
}

sub admin_additional
{
	my $o = shift;
	
	print '<tr><td valign="top">Адрес&nbsp;на&nbsp;сайте:</td><td>',$o->can('site_href')?$o->site_href():'Нет.','</td></tr>';
}


package plgnSite::ObjectHook;



1;
