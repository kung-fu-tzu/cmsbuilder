package JDBI::vtypes::file;
use CGI 'param';
our @ISA = 'JDBI::VType';
use JDBI;
our $dont_html_filter = 1;
# ���������� ����� � ��� �� ����������� - $val �������� ��� �����.
# � ������ �������� �� ������.

# ����� ���� ######################################################

sub table_cre
{
    return ' VARCHAR(10) ';
}

sub aview
{
    my $class = shift;
    my $name = shift;
    my $val = shift;
    my $obj = shift;
    my ($file_href,$file_del,$not_perm,$block);
    
    my $props = \%{ ref($obj).'::props' };
    
    if( $obj->{$name} ){ $file_href = '<a target="_new" href="'.$obj->file_href($name).'">�������...</a>'; }
    if( $obj->{$name} and group()->{'files'} ){ $file_del = '������� - <input type=checkbox name="'.$name.'_todel">'; }
    
    if(!$JDBI::group->{'files'}){
	$not_perm = '\n\n������ ������ ��� ����� ������ �� ���������!';
	$block = 'disabled';
    }
    
    my @exts = split(/\s+/,$props->{$name}{'ext'});
    shift @exts;
    my $ext_list = join(', ', @exts);
    
    my $ret = '<input '.$block.' type="file" cols="30" name="'.$name.'">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.$file_del.'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'
	      .'<a href="#" onclick="alert(\'���������� ����������: '.$ext_list.'.\\n������������ ������: '.$props->{$name}{'msize'}.'��'.$not_perm .'\'); return false;">�������...</a>&nbsp;&nbsp;&nbsp;'
	      .$file_href;
    
    return $ret;
}

sub aedit
{
    my $class = shift;
    my $name = shift;
    my $val = shift;
    my $obj = shift;
    
    if(!$JDBI::group->{'files'}){
	if($val){ $obj->err_add('������ ������ ��� ����� ������ �� ���������.') }
	return $obj->{$name};
    }
    
    my $props = \%{ ref($obj).'::props' };
    my $id = $obj->{ID};
    my ($buff,$len,$todel);
    if($id =~ m/\D/){ return 0; }
    
    my $fdir = $JConfig::path_wwfiles.'/';
    
    if($val){
	
	unlink( $fdir.$obj->myurl().'_'.$name.'.'.$obj->{$name} );
	
	$val =~ m/(\.\w+$)/;
	my $ext = $1;
	
	$ext =~ s/\W//g;
	
	if( index( $props->{$name}{'ext'}, ' '.lc($ext).' ') < 0 and $props->{$name}{'ext'} ne '*' ){
	    
	    $obj->err_add('���������� �����, '.$ext.', �����������.');
	    return;
	}
	
	$obj->{$name} = $ext;
	
	my $ores;
	$ores = open(DBO_FILE, "> $fdir".$obj->myurl().'_'.$name.'.'.$obj->{$name});
	
	if( !$ores ){
	    $obj->err_add('���������� ������� ����: '.$fdir.$obj->myurl().'_'.$name.'.'.$obj->{$name}.'.');
	    return;
	}
	
	binmode DBO_FILE;
	while ( read($val,$buff,2048) ) {
	    print DBO_FILE $buff;
	    $len += 2048;
	    
	    if( $len > ($props->{$name}{msize}*1024) ){
	        $obj->err_add('���� ������� �����.');
	        return;
	    }
	    
	}
	close DBO_FILE;
	
	return $ext;
	
    }else{
	
	$todel = param($name.'_todel');
	
	if($todel) {
	    unlink( $fdir.$obj->myurl().'_'.$name.'.'.$obj->{$name} );
	    return '';
	}
    }
    
    return $obj->{$name};
}

sub del
{
    my $class = shift;
    my $name = shift;
    my $val = shift;
    my $obj = shift;
    
    unlink( $JConfig::path_wwfiles.'/'.$obj->myurl().'_'.$name.'.'.$obj->{$name} );
}

1;