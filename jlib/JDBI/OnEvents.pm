package JDBI::OnEvents;
use strict qw(subs vars);

###################################################################################################
# Методы обработки событий
###################################################################################################

# Когда элемент получает новую позицию в пределах массива
sub on_Array_elem_moveto
{
	my $o = shift;
	my $from = shift;
	my $to = shift;
	
	$o->{'_ENUM'} = $to;
}

# После того, как элемент вырезали из $from
sub on_Array_elem_cut
{
	my $o = shift;
	my $from = shift;
	
	delete $o->{'_ENUM'};
}

# После того, как элемент вставили в $to
sub on_Array_elem_paste {}

return 1;