# (с) Леонов П.А., 2005

package JDBI::vtypes::checkbox;
our @ISA = 'JDBI::VType';
# Галочка ###################################################

our $admin_own_html = 1;

sub table_cre
{
	return ' INT(1) ';
}

sub aview
{
	my $class = shift;
	my $name = shift;
	my $val = shift;
	my $obj = shift;
	
	my $p = $obj->props();
	
	if($val){$val = 'checked'}
	
	my $ret = '
		<tr>
			<td><label for="checkbox_'.$name.'">'.$p->{$name}{'name'}.'</label></td>
			<td valign=top><input id="checkbox_'.$name.'" type=checkbox name="'.$name.'" '.$val.'></td>
		</tr>
	';
	
	return $ret;
}
#
sub aedit
{
	my $class = shift;
	my $name = shift;
	my $val = shift;
	
	if($val){$val = 1}
	
	return $val;
}

1;