# (�) ������ �.�., 2005

package CMSBuilder::DBI::vtypes::radio;
use strict qw(subs vars);
our @ISA = 'CMSBuilder::DBI::VType';
# ������������� #############################################

sub table_cre
{
	my $c = shift;
	my $p = shift;
	my $vars = $p->{'variants'};
	
	return " ENUM( '".join("', '",(map {keys %$_} @$vars))."' )  ";
}

sub aview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	my $p = $obj->props();
	
	my %vars = map {%$_} @{$p->{$name}->{'variants'}};
	
	my($ret,$i);
	for my $var (sort(keys(%vars)))
	{
		$ret .= '<input id="'.$name.'_'.++$i.'" name="'.$name.'" type="radio"'.($var eq $val?' checked':'').' value="'.$var.'" /><label for="'.$name.'_'.$i.'">'.$vars{$var}.'</label><br>';
	}
	
	return $ret;
}

1;