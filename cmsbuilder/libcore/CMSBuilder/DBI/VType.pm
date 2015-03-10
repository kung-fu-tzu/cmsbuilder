# (�) ������ �.�., 2005

# ������� ����� ��� ���������� �����.
package CMSBuilder::DBI::VType;
use strict qw(subs vars);

our $filter;			# ��� �������� ����� ������������ ����, ���� ����� ���������
						# �������������� �������� ( �-��� filter_in() � filter_out() )

our $virtual;			# �� ����� ������� � �������

our $admin_own_html;	# aview() ���������� �� ��������, � ���� HTML ���.
						# ������: CMSBuilder::DBI::vtypes::miniword

our $property;			# ������ � ������ �������������� ������� (��� � Delphi)

#-------------------------------------------------------------------------------


sub table_cre
{
	return ' CHAR(100) ';
}

sub aview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	$val =~ s/\&/\&amp;/g;
	$val =~ s/\"/\&quot;/g;
	$val =~ s/\</\&lt;/g;
	$val =~ s/\>/\&gt;/g;
	
	return '<input type="text" name="'.$name.'" value="'.$val.'">';
}

sub aedit
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	return $val;
}

#-------------------------------------------------------------------------------

sub prop_read
{
	my $c = shift;
	my ($name,$obj) = @_;
	
	return $obj->{$name};
}

sub prop_write
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
	
	return $obj->{$name} = $val;
}

#-------------------------------------------------------------------------------


sub filter_insert
{
	my $c = shift;
	my $name = shift;
	
	return;
}

sub filter_load
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
}

sub filter_save
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
}


#-------------------------------------------------------------------------------


sub del
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
}

sub copy
{
	my $c = shift;
	my ($name,$val,$obj,$nobj) = @_;
	
	return $val;
}


1;