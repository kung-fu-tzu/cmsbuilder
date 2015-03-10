sub jchown
{
    my $url = param('url');
    my $uid = param('uid');
    my $obj = url($url);
    my $tu;
    
    if(!$JDBI::group->{'root'}){ $obj->err_add('� ��� ��� ���� ������ ��������� ���������.'); return; }
    
    sess()->{'admin_refresh_left'} = 0;
    
    if($uid){
	
	$uid =~ s/\D//g;
	
	$tu = User->new();
	$tu->load($uid);
	
	if($tu->{'ID'} < 1){ $obj->err_add('��������� ������������ �� ����������.'); return; }
	
	$obj->ochown($uid);
	$obj->save();
	
	return;
    }
    
    $do_list = 0;
    
    my $nowu = User->new( $obj->{'OID'} );
    
    print '��������� ��������� ��� ��������: <b>',$obj->name(),'</b><br>';
    print '������� �������� ��������: <b>',$nowu->name(),'</b><br>';
    
    print '<br><br>�������� ������ ���������:<br><br>';
    
    my $count = 0;
    for $tu (User->sel_where(' 1 ')){
	
	if($tu->{'ID'} == $nowu->{'ID'}){ next; }
	print '<img src="img/dot.gif" align="absmiddle"> <a href="?act=chown&url=',$url,'&uid=',$tu->{'ID'},'">',$tu->name(),'</a><br>';
	$count++;
    }
    
    if(!$count){ print '<center><b>��� ������������� ��� �����������.</b></center>'; }
}

1;