# Файл ######################################################

$vtypes{'file'}{'table_cre'} = sub {
    
    my %elem = %{$_[0]};
    
    return ' INT ';
};

$vtypes{'file'}{'aview'} = sub {

    my $name = shift;
    my $val = shift;
    my $obj = shift;
    my $file_href;
    
    if( $obj->{$name} ){ $file_href = "<a target=_new href='".$obj->file_href($name)."'>скачать</a>"; }
    
    my $ret = '<input class="winput" type=checkbox name="'.$name.'_todel"> - удалить. <input type=file cols=30 name="'.$name.'"> '.$file_href;
    
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
	
	open DBO_FILE, "> $fdir".ref($obj)."_${name}_$id".$props{$name}{ext};
	
	binmode DBO_FILE;
	while ( read($val,$buff,2048) and $len <= $props{$name}{msize} ) {
	    print DBO_FILE $buff;
	    $len += 2048;
	}
	close DBO_FILE;
	
	return 1;
    
    }else{
	$todel = eml::param($name.'_todel');
	
	if($todel) {
	    unlink( $fdir.ref($obj)."_${name}_$id".$props{$name}{ext} );
	    return 0;
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
    
    unlink( $fdir.ref($obj)."_${name}_$id".$props{$name}{ext} );
};

1;