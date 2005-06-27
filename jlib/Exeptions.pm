# (с) Леонов П.А., 2005

package Exeptions;
use strict qw(subs vars);
our @ISA = ('Exporter');
our @EXPORT = ('try','catch','throw','deftype');
our $etype;

sub try(&$)
{
	my $code = shift;
	my $ccode = shift;
	
	my @ret = eval{ &$code };
	
	if($@){ &$ccode($etype); }
	
	return @ret;
}

sub catch($&)
{
	my $ccode = shift;
	return $ccode;
}

sub throw($)
{
	my $type = shift;
	$etype = $type;
	die $type;
}



1;