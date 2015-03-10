sub move2
{
    my $url = param('url');
    my $uto = param('to');
    my $enum = param('enum');
    
    my $from = url($url);
    my $elem = $from->elem($enum);
    
    if(!$from->access('w')){ $from->err_add('� ��� ��� ���������� �������� ���� �������.'); return; }
    if(!$elem->access('w')){ $from->err_add('� ��� ��� ���������� �������� ������������ �������.'); return; }
    
    if($uto){
	
	my $to = url($uto);
	if(!$to->access('a')){ $from->err_add('� ��� ��� ���������� ��������� � ������� ����������.'); return; }
	if(!$to->elem_can_paste($elem)){ return; }
	
	$elem = $from->elem_cut($enum);
	$to->elem_paste($elem);
	
	return;
    }
    
    sess()->{'admin_refresh_left'} = 0;
    $do_list = 0;
    
    my $eclass = ref($elem);
    
    print '�������� ������, � ������� ����������� �������: <b>',$elem->name(),'</b>.<br><br>';
    
    my $count = 0;
    
    my $c;
    for $c (@JDBI::classes,@JDBI::modules){
	
	if( index( ${$c.'::add'}, ' '.$eclass.' ') < 0 and ${$c.'::add'} ne '*' ){ next; }
	
	my $d;
	for $d ($c->sel_where(' 1 ')){
	    
	    unless($d->elem_can_paste($elem)){ next; }
	    if(!$d->access('a')){ next; }
	    
	    print '<img src="',$d->admin_icon(),'" align="absmiddle">&nbsp;&nbsp;<a href="?act=move2&url=',$from->myurl(),'&to=',$d->myurl(),'&enum=',$enum,'&ref=0">',$d->name(),'</a><br>';
	    $count++;
	}
    }
    
    if(!$count){ print '<center><b>��� �������� ��� �����������.</b></center>'; }
}

1;