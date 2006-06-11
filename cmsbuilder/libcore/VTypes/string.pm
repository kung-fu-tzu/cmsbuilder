# (с) Леонов П.А., 2005

package CMSBuilder::DBI::vtypes::string;
use strict qw(subs vars);
our @ISA = 'CMSBuilder::DBI::VType';
# Строка ####################################################

sub table_cre
{
	my $c = shift;
	my $p = shift;
	
	if($p->{'big'})
	{
		return ' TEXT ';
	}
	else
	{
		return ' VARCHAR( '.($p->{'length'} || 255).' ) ';
	}
}

sub aview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	$val =~ s/\'/\&#039;/g;
	$val =~ s/\"/\&quot;/g;
	$val =~ s/\</\&lt;/g;
	$val =~ s/\>/\&gt;/g;
	
	return '<input class="winput" type=text name="'.$name.'" value="'.$val.'">';
}

1;