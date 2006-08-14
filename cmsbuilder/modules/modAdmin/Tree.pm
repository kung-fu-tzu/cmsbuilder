# CMSBuilder © Леонов П. А., 2005-2006

package modAdmin::Tree;
use strict qw(subs vars);
use utf8;

our @ISA = qw(modAdmin::RootElement);

sub _cname {'Модуль с древовидной структурой'}

#———————————————————————————————————————————————————————————————————————————————


sub admin_view_left
{
	my $o = shift;
	
	if($o->have_funcs())
	{
		$o->modAdmin::Simple::admin_view_left(@_);
	}
	
	return $o->CMSBuilder::DBI::Array::admin_view_left(@_);
}


1;