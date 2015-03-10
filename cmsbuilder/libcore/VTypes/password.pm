# (�) ������ �.�., 2005

package CMSBuilder::DBI::vtypes::password;
use strict qw(subs vars);
our @ISA = 'CMSBuilder::DBI::VType';
# ������ ####################################################

our $filter = 1;

use CMSBuilder::Utils;

sub table_cre
{
	return ' VARCHAR(32) ';
}


sub filter_load
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
	
	$obj->{'_pashash_'.$name} = $val;
}

sub filter_save
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
	
	unless($val){ return ''; }
	
	if($obj->{'_pashash_'.$name} ne $val)
	{
		$val = MD5($val);
	}
	
	return $val;
}

sub aview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	my ($ret,$do);
	
	if($val)
	{
		$ret = '����������.';
		$do = '��������...';
	}
	else
	{
		$ret = '<span style="color:#ff0000">�� ����������.</span>';
		$do = '����������...';
	}
	
	$ret .= '
	&nbsp;&nbsp;&nbsp;&nbsp;
	<button onclick="
		'.$name.'_input.style.display = \'inline\';
		'.$name.'_ch.style.display = \'none\';
		'.$name.'_doch.value = \'yes\';
		return false;
		"
	id="'.$name.'_ch">'.$do.'</button>
	<span style="display: none" id="'.$name.'_input"><br>';
	
	if($obj->props()->{$name}{'check'} && $obj->{$name})
	{
		$ret .=
		'
			<input class="ainput" type="password" name="'.$name.'_check"> (������� ������)<br><br>
		';
	}
	
	$ret .=
	'
	<input class="ainput" type="password" name="'.$name.'"> (������)<br>
	<input class="ainput" type="password" name="'.$name.'_verif"> (�������������)
	</span>
	<input type="hidden" id="'.$name.'_doch" name="'.$name.'_doch">
	';
	
	return $ret;
}

sub aedit
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	unless($r->{$name.'_doch'}){ return $obj->{$name} }
	
	my $verif = $r->{$name.'_verif'};
	
	if($obj->props()->{$name}{'check'} && $obj->{$name})
	{
		if(MD5($r->{$name.'_check'}) ne $obj->{$name})
		{
			$obj->err_add('������� ������ ������ �������.');
			return $obj->{$name};
		}
	}
	
	if($val ne $verif)
	{
		$obj->err_add('��������� ������ � ������������� �� ���������.');
		return $obj->{$name};
	}
	
	return $val;
}

sub copy { return ''; }


1;