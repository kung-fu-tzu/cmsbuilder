# (�) ������ �.�., 2005

package JDBI::vtypes::password;
our @ISA = 'JDBI::VType';
use CGI 'param';
# ������ ####################################################

sub table_cre
{
	my $class = shift;
	my %elem = %{$_[0]};
	
	return ' VARCHAR( '.$elem{length}.' ) ';
}

sub aview
{
	my $class = shift;
	my $name = shift;
	my $val = shift;
	my ($ret,$do);
	
	if($val)
	{
		$ret = '����������.';
		$do = '��������...';
	}
	else
	{
		$ret = '<font color="#FF0000">�� ����������.</font>';
		$do = '����������...';
	}
	
	$ret .= '
	&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="#" onclick="
		'.$name.'_input.style.display = \'inline\';
		'.$name.'_ch.style.display = \'none\';
		'.$name.'_doch.value = \'yes\';
		return false;
		"
	id="'.$name.'_ch">'.$do.'</a>
	<span style="DISPLAY: none" id="'.$name.'_input">
	<input class="ainput" type=password name="'.$name.'">
	<input class="ainput" type=password name="'.$name.'_verif">
	</span>
	<input type="hidden" id="'.$name.'_doch" name="'.$name.'_doch">
	';
	
	return $ret;
}

sub aedit
{
	my $class = shift;
	my $name = shift;
	my $val = shift;
	my $obj = shift;
	
	my $verif = param($name.'_verif');
	my $do = param($name.'_doch');
	
	if(!$do){ return $obj->{$name} }
	
	if($val ne $verif)
	{
		$obj->err_add('�������� ������ �� ���������. ������ �� ������.');
		return $obj->{$name};
	}
	
	return $val;
}

1;