# (с) Леонов П.А., 2005

package JDBI::vtypes::date;
our @ISA = 'JDBI::VType';
# Дата ####################################################

sub table_cre
{
	return ' DATE ';
}

sub aview
{
	my $class = shift;
	my $name = shift;
	my $val = shift;
	my $ret;
	
	my @a = split(/\-/,$val);
	
	if($a[0] < 1){$a[0] = ''}
	if($a[1] < 1){$a[1] = ''}
	if($a[2] < 1){$a[2] = ''}
	
	$ret = "<input cols=4 style='WIDTH: 20px' type=text name='${name}_d' value=\"$a[2]\">";
	$ret .= "<input cols=4 style='WIDTH: 20px' type=text name='${name}_m' value=\"$a[1]\">";
	$ret .= "<input cols=6 style='WIDTH: 50px' type=text name='${name}_y' value=\"$a[0]\">";
	
	return $ret;
}

sub aedit
{
	my $class = shift;
	my $name = shift;
	my $val;
	
	my $d = eml::param($name.'_d');
	my $m = eml::param($name.'_m');
	my $y = eml::param($name.'_y');
	
	$val = $y.'-'.$m.'-'.$d;
	
	return $val;
}

1;