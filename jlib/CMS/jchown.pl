sub jchown
{
	my $url = param('url');
	my $uid = param('uid');
	my $obj = url($url);
	my $tu;
	
	unless($JDBI::group->{'root'}){ $obj->err_add('У Вас нет прав менять владельца элементам.'); return; }
	
	sess()->{'admin_refresh_left'} = 0;
	
	if($uid){
		
		$uid =~ s/\D//g;
		
		$tu = User->new($uid);
		
		if($tu->{'ID'} < 1){ $obj->err_add('Указанный пользователь не существует.'); return; }
		
		$obj->ochown($uid);
		$obj->save();
		$obj->reload();
		
		return;
	}
	
	$do_list = 0;
	
	my $nowu = User->new( $obj->{'OID'} );
	
	print 'Изменение владельца для элемента: <b>',$obj->name(),'</b><br>';
	print 'Текущий владелец элемента: <b>',$nowu->name(),'</b><br>';
	
	print '<br><br>Выберете нового владельца:<br><br>';
	
	my $count = 0;
	for $tu (User->sel_where(' 1 ORDER BY `name`')){
		
		if($tu->{'ID'} == $nowu->{'ID'}){ next; }
		print $tu->admin_name('?act=chown&url='.$url.'&uid='.$tu->{'ID'});
		$count++;
	}
	
	unless($count){ print '<center><b>Нет пользователей для отображения.</b></center>'; }
}

1;