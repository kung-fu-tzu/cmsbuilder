# (�) ������ �.�., 2005

package JDBI::NoBase;
use strict qw(subs vars);


###################################################################################################
# ������, ���������� ���������������� ������ � ����� ������
###################################################################################################

sub count { return 1; }

sub del {}

sub sel_one {}
sub sel_where {}
sub sel_sql {}

# ������������� �������� ����� ���������� � ������������� ������ ����� ������
sub reload
{
	my $o = shift;
	$o->{'name'} = $o->cname();
	$o->{'ID'} = 1;
	$o->{'OID'} = 1;
} 

sub save {}

sub insert { return 1; }

sub table_have { return 1; }

sub table_fix { return 0; }

sub table_cre {}

sub check {}

1;