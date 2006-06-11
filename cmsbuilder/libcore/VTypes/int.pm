# (с) Леонов П.А., 2005

package CMSBuilder::DBI::vtypes::int;
use strict qw(subs vars);
our @ISA = 'CMSBuilder::DBI::VType';
# Число ####################################################

sub table_cre
{
	my $c = shift;
	my $p = shift;
	
	return ' INT('.($p->{'length'} || 11).') ';
}

sub aview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	return '<input size="4" type="text" name="'.$name.'" value="'.$val.'">';
}

sub aedit
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	$val =~ s/\D//g;
	if($val eq ''){ $val = 0; }
	
	return $val;
}

1;