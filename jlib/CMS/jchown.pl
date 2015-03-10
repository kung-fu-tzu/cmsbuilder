sub jchown
{
	my $url = param('url');
	my $uid = param('uid');
	my $obj = url($url);
	my $tu;
	
	unless($JDBI::group->{'root'}){ $obj->err_add('� ��� ��� ���� ������ ��������� ���������.'); return; }
	
	sess()->{'admin_refresh_left'} = 0;
	
	if($uid){
		
		$uid =~ s/\D//g;
		
		$tu = User->new($uid);
		
		if($tu->{'ID'} < 1){ $obj->err_add('��������� ������������ �� ����������.'); return; }
		
		$obj->ochown($uid);
		$obj->save();
		$obj->reload();
		
		return;
	}
	
	$do_list = 0;
	
	my $nowu = User->new( $obj->{'OID'} );
	
	print '��������� ��������� ��� ��������: <b>',$obj->name(),'</b><br>';
	print '������� �������� ��������: <b>',$nowu->name(),'</b><br>';
	
	print '<br><br>�������� ������ ���������:<br><br>';
	
	my $count = 0;
	for $tu (User->sel_where(' 1 ORDER BY `name`')){
		
		if($tu->{'ID'} == $nowu->{'ID'}){ next; }
		print $tu->admin_name('?act=chown&url='.$url.'&uid='.$tu->{'ID'});
		$count++;
	}
	
	unless($count){ print '<center><b>��� ������������� ��� �����������.</b></center>'; }
}

1;