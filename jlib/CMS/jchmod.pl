sub jchmod
{
    my $url = param('url');
    my $chact = param('chact');
    my $obj = url($url);
    
    if(!$obj->access('c')){ $obj->err_add('У Вас нет прав менять разрешения этому элементу.'); return; }
    
    $do_list = 0;
    sess()->{'admin_refresh_left'} = 0;
    
    
    if($chact eq 'edit'){
	
	my $old_code = $obj->{'_access_code'};
	
	$obj->access_edit();
	
	$obj->{'_access_geted'} = 0;
	$obj->access('r');
	
	if($obj->{'_access_code'} ne $old_code){ sess()->{'admin_refresh_left'} = 1; }
	
	if(param('submit') eq 'OK'){ $do_list = 1; return; }
    }
    if($chact eq 'addlist'){ $obj->access_add_list(); return; }
    if($chact eq 'add'){ $obj->access_add(param('memb')); }
    if($chact eq 'del'){ $obj->access_del(param('memb')); }
    
    $obj->access_view();
}

1;