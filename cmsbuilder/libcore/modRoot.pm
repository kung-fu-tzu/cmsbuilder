# (с) Леонов П.А., 2005

package modRoot;
use strict qw(subs vars);
our @ISA = 'CMSBuilder::DBI::Array';

sub _cname {'Корень модулей'}
sub _have_icon {1}
sub _one_instance {1}
sub _add_classes {'CMSBuilder::DBI::Module'}

#-------------------------------------------------------------------------------


use CMSBuilder::Utils;

sub name { return $_[0]->_cname(@_); }

sub elem_paste
{
	my $o = shift;
	
	my $ret = $o->SUPER::elem_paste(@_);
	
	my $to = shift;
	$to->papa_set();
	$to->save();
	
	return $ret;
}

sub access
{
	my $o = shift;
	my $type = shift;
	
	if($type eq 'r' || $type eq 'x'){ return 1; }
	
	return $o->SUPER::access($type);
}


1;