# Любой файл ######################################################

$vtypes{'file'}{'table_cre'} = sub {
    
    my %elem = %{$_[0]};
    
    return ' VARCHAR(10) ';
};

$vtypes{'file'}{'aview'} = sub {
    
    my $name = shift;
    my $val = shift;
    my $obj = shift;
    my $file_href;
    
    my %props = $obj->props();
    
    if( $obj->{$name} ){ $file_href = "<a target=_new href='".$obj->file_href($name)."'>скачать</a>"; }
    
    my @exts = split(/\s+/,$props{$name}{'ext'});
    shift @exts;
    my $ext_list = join(', ', @exts);
    
    my $ret = '&nbsp;<a href="#" title="Помощь" onclick="alert(\'Допустимые расширения: '.$ext_list.'.\\nМаксимальный размер: '.$props{$name}{'msize'}.'КБ\'); return false;">?</a>&nbsp;&nbsp;&nbsp;'
	      .'<input type=checkbox name="'.$name.'_todel"> - удалить. <input type=file cols=30 name="'.$name.'"> '.$file_href;
    
    return $ret;
};

$vtypes{'file'}{'aedit'} = sub {
    
    my $name = shift;
    my $val = shift;
    my $obj = shift;
    
    my %props = $obj->props();
    my $id = $obj->{ID};
    my ($buff,$len,$todel);
    if($id =~ m/\D/){ return 0; }
    
    my $fdir = $eml::files_dir;
    
    if($val){
	
	unlink( $fdir.$obj->myurl()."_${name}".'.'.$obj->{$name} );
	
	$val =~ m/(\.\w+$)/;
	my $ext = $1;
	
	$ext =~ s/\W//g;
	
	if( index( $props{$name}{'ext'}, ' '.$ext.' ') < 0 and $props{$name}{'ext'} ne '*' ){
	    
	    $obj->err_add('Расширение файла, '.$ext.', недопустимо.');
	    return;
	}
	
	$obj->{$name} = $ext;
	
	my $ores;
	$ores = open(DBO_FILE, "> $fdir".$obj->myurl()."_${name}".'.'.$obj->{$name});
	
	if( !$ores ){
	    $obj->err_add('Невозможно открыть файл: '.$fdir.$obj->myurl()."_${name}".'.'.$obj->{$name}.'.');
	    return;
	}
	
	binmode DBO_FILE;
	while ( read($val,$buff,2048) ) {
	    print DBO_FILE $buff;
	    $len += 2048;
	    
	    if( $len > ($props{$name}{msize}*1024) ){
	        $obj->err_add('Файл слишком велик.');
	        return;
	    }
	    
	}
	close DBO_FILE;
	
	return $ext;
	
    }else{
	
	$todel = eml::param($name.'_todel');
	
	if($todel) {
	    unlink( $fdir.$obj->myurl()."_${name}".'.'.$obj->{$name} );
	    return '';
	}
    }
    
    return $obj->{$name};
};

$vtypes{'file'}{'del'} = sub {
    
    my $name = shift;
    my $val = shift;
    my $obj = shift;
    
    my %props = $obj->props();
    my $id = $obj->{ID};
    
    my $fdir = $eml::files_dir;
    
    unlink( $fdir.$obj->myurl()."_${name}".'.'.$obj->{$name} );
};

1;