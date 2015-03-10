# (�) ������ �.�., 2005

package CMSBuilder::DBI::vtypes::text;
use strict qw(subs vars);
our @ISA = 'CMSBuilder::DBI::VType';
# ����� #####################################################

our $admin_own_html = 1;

sub table_cre
{
	return ' TEXT ';
}

sub aedit
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	$val =~ s/\r\n/\n/g;
	$val =~ s/\r//g;
	$val =~ s/\n/<br>/g;
	
	return $val;
}

sub aview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	$val =~ s/<br>/\n/g;
	
	$val =~ s/\&/\&amp;/g;
	$val =~ s/\"/\&quot;/g;
	$val =~ s/\</\&lt;/g;
	$val =~ s/\>/\&gt;/g;
	
	return
	'
	<tr><td colspan="2">
		'.$obj->props()->{$name}{'name'}.':<br>
		<textarea class="winput" cols=42 rows=15 name="'.$name.'">'.$val.'</textarea>
	</td></tr>
	';
}


1;