# (с) Леонов П.А., 2005

package CMSBuilder::Admin::Tree;
use strict qw(subs vars);
use utf8;

our @ISA = qw(CMSBuilder::Admin::RootElement);

sub _cname {'Модуль с древовидной структурой'}

#———————————————————————————————————————————————————————————————————————————————


sub admin_view_left
{
	my $o = shift;
	
	if($o->have_funcs())
	{
		$o->CMSBuilder::Admin::Simple::admin_view_left(@_);
	}
	
	return $o->CMSBuilder::DBI::Array::AAdmin::admin_view_left(@_);
}


1;