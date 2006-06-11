# (�) ������ �.�., 2005

package CMSBuilder::DBI::vtypes::time;
use strict qw(subs vars);
our @ISA = 'CMSBuilder::DBI::VType';
# ����� ####################################################

sub table_cre
{
	return ' TIME ';
}

sub aview
{
	my($c,$name,$val,$obj,$r) = @_;
	my $ret;
	
	my @a = split(/\:/,$val);
	
	@a = map { $_ < 1?$_='':0; } @a;
	
	
	
	return
	'
	<input style="WIDTH: 25px" type="text" name="'.$name.'_h" value="'.$a[0].'">
	<input style="WIDTH: 25px" type="text" name="'.$name.'_m" value="'.$a[1].'">
	<input style="WIDTH: 25px" type="text" name="'.$name.'_s" value="'.$a[2].'">
	';
}

sub aedit
{
	my($c,$name,$val,$obj,$r) = @_;
	
	my $h = $r->{$name.'_h'};
	my $m = $r->{$name.'_m'};
	my $s = $r->{$name.'_s'};
	
	$val = $h.':'.$m.':'.$s;
	
	return $val;
}

1;