# CMSBuilder © Леонов П. А., 2005-2006

package modShop;
use strict qw(subs vars);
use utf8;

our @ISA = qw(modTemplates::Interface CMSBuilder::Module);

sub _template_export
{qw/
basket_html
/}

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder;

sub basket_html
{
	my $c = shift;
	
	print $c;
}

sub mod_load
{
	my $c = shift;
	
	unshift(@modCatalog::Object::ISA,'modShop::Object');
	unshift(@CatDir::ISA,'modShop::Dir');
	unshift(@modUsers::UserMember::ISA,'modShop::User');
	
	cmsb_hookp 'modCatalog::Ware', 'modShop::Ware';
}


1;