# Любой файл ######################################################

$vtypes{'anyfile'}{'table_cre'} = sub {
    
    my %elem = %{$_[0]};
    
    return ' VARCHAR(10) ';
};

$vtypes{'anyfile'}{'aview'} = sub {
    
    my $name = shift;
    my $val = shift;
    my $obj = shift;
    my $file_href;
    
    if( $obj->{$name} ){ $file_href = "<a target=_new href='".$obj->anyfile_href($name)."'>скачать</a>"; }
    
    my $ret = '<input type=checkbox name="'.$name.'_todel"> - удалить. <input type=file cols=30 name="'.$name.'"> '.$file_href;
    
    return $ret;
};

$vtypes{'anyfile'}{'aedit'} = sub {
    
    my $name = shift;
    my $val = shift;
    my $obj = shift;
    
    my %props = $obj->props();
    my $id = $obj->{ID};
    my ($buff,$len,$todel);
    if($id =~ m/\D/){ return 0; }
    
    my $fdir = $eml::files_dir;
    
    if($val){
	
	unlink( $fdir.ref($obj)."_${name}_$id".$obj->{$name} );
	
	$val =~ m/(\.\w+$)/;
	my $ext = $1;
	
	$ext =~ s/[^\w\.]//g;
	
	$obj->{$name} = $ext;
	
	open DBO_FILE, "> $fdir".ref($obj)."_${name}_$id".$obj->{$name};
	
	binmode DBO_FILE;
	while ( read($val,$buff,2048) and $len <= $props{$name}{msize} ) {
	    print DBO_FILE $buff;
	    $len += 2048;
	}
	close DBO_FILE;
	
	return $ext;
	
    }else{
	
	$todel = eml::param($name.'_todel');
	
	if($todel) {
	    unlink( $fdir.ref($obj)."_${name}_$id".$obj->{$name} );
	    return '';
	}
    }
    
    return $obj->{$name};
};

$vtypes{'anyfile'}{'del'} = sub {
    
    my $name = shift;
    my $val = shift;
    my $obj = shift;
    
    my %props = $obj->props();
    my $id = $obj->{ID};
    
    my $fdir = $eml::files_dir;
    
    unlink( $fdir.ref($obj)."_${name}_$id".$obj->{$name} );
};

1;