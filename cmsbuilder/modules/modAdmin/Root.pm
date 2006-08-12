# CMSBuilder © Леонов П. А., 2005

package modAdmin::Root;
use strict qw(subs vars);
use utf8;

our @ISA = qw(CMSBuilder::DBI::Array);

sub _cname {'Корень модулей'}
sub _have_icon {1}
sub _one_instance {1}
sub _add_classes {'modAdmin::RootElement'}
sub _aview {'name'}


sub _props
{
	'name'		=> { 'type' => 'string', 'name' => 'Название' },
}

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder::Utils;

sub name
{
	my $o = shift;
	return $o->id eq '1' && !$o->{'name'} ? $o->_cname(@_) : $o->SUPER::name;
}

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