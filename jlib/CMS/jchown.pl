sub jchown
{
    my $url = param('url');
    my $uid = param('uid');
    my $obj = url($url);
    my $tu;
    
    if(!$JDBI::group->{'root'}){ $obj->err_add('У Вас нет прав менять владельца элементам.'); return; }
    
    sess()->{'admin_refresh_left'} = 0;
    
    if($uid){
	
	$uid =~ s/\D//g;
	
	$tu = User->new();
	$tu->load($uid);
	
	if($tu->{'ID'} < 1){ $obj->err_add('Указанный пользователь не существует.'); return; }
	
	$obj->ochown($uid);
	$obj->save();
	
	return;
    }
    
    $do_list = 0;
    
    my $nowu = User->new( $obj->{'OID'} );
    
    print 'Изменение владельца для элемента: <b>',$obj->name(),'</b><br>';
    print 'Текущий владелец элемента: <b>',$nowu->name(),'</b><br>';
    
    print '<br><br>Выберете нового владельца:<br><br>';
    
    my $count = 0;
    for $tu (User->sel_where(' 1 ')){
	
	if($tu->{'ID'} == $nowu->{'ID'}){ next; }
	print '<img src="img/dot.gif" align="absmiddle"> <a href="?act=chown&url=',$url,'&uid=',$tu->{'ID'},'">',$tu->name(),'</a><br>';
	$count++;
    }
    
    if(!$count){ print '<center><b>Нет пользователей для отображения.</b></center>'; }
}

1;