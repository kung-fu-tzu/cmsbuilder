package JDBI::vtypes::ClassList;
our @ISA = 'JDBI::VType';
# Список ####################################################

sub table_cre
{
	return " INT(11) ";
}

sub aview
{
	my $class = shift;
	my $name = shift;
	my $val = shift;
	my $obj = shift;
	
	my $props = \%{ ref($obj).'::props' };
	
	my $cn = $props->{$name}{'class'};
	
	my $to;
	my $ret = '<SELECT name="'.$name.'">';
	my $chkd = '';
	
	my $tc = $cn->new();
	
	for $to ($tc->sel_where(' 1 ')){
	
	if($to->{'ID'} eq $val){ $chkd = ' selected '; }else{ $chkd = ' '; }
	$ret .= '<OPTION '.$chkd.' value="'.$to->{'ID'}.'">'.$to->name().'</OPTION>';
	}
	
	$ret .= '</SELECT>';
	
	return $ret;
}

sub aedit
{
	my $class = shift;
	my $name = shift;
	my $val = shift;
	
	return $val;
}

1;