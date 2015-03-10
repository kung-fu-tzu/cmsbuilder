package JDBI::OnEvents;
use strict qw(subs vars);

###################################################################################################
# ������ ��������� �������
###################################################################################################

# ����� ������� �������� ����� ������� � �������� �������
sub on_Array_elem_moveto
{
	my $o = shift;
	my $from = shift;
	my $to = shift;
	
	$o->{'_ENUM'} = $to;
}

# ����� ����, ��� ������� �������� �� $from
sub on_Array_elem_cut
{
	my $o = shift;
	my $from = shift;
	
	delete $o->{'_ENUM'};
}

# ����� ����, ��� ������� �������� � $to
sub on_Array_elem_paste {}

return 1;