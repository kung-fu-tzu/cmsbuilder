
# Микроворд #####################################################

$vtypes{'microword'}{table_cre} = sub {
    
    return ' TEXT ';
    
};

$vtypes{'microword'}{'aview'} = sub {

    my $name = shift;
    my $val = shift;
    
    $val =~ s/\"/\&quot;/g;
    $val =~ s/\</\&lt;/g;
    $val =~ s/\>/\&gt;/g;
    
    my $ret = <<MICRO;
    
    <TEXTAREA class=admin_input name="${name}" style="DISPLAY: none; HEIGHT: 148px;  WIDTH: 300px">$val</TEXTAREA>
    <script>${name}_mw_loaded = 0;</script>
    <iframe frameborder=1 class=admin_input src="/admin/microword.html" id="${name}_mw" style="HEIGHT: 150px; WIDTH: 300px"
    
        onload="${name}_mw.document.body.innerHTML = ${name}.value; ${name}_mw.document.designMode = 'On'; ${name}_mw_loaded = 1;"
        onmouseout = "if(!${name}_mw_loaded) return; ${name}.value = ${name}_mw.document.body.innerHTML"
        onmouseover = "if(!${name}_mw_loaded) return; ${name}.value = ${name}_mw.document.body.innerHTML"
        onkeyup = "if(!${name}_mw_loaded) return; ${name}.value = ${name}_mw.document.body.innerHTML"
        
    ></iframe><br>
    <INPUT type="button" value="HTML"   onclick=' ${name}.style.display = "block"; document.all.${name}_mw.style.display = "none";  ${name}_to_norm.style.display = "block"; ${name}_to_html.style.display = "none";'  id="${name}_to_html">
    <INPUT type="button" value="Normal" onclick=' ${name}.style.display = "none";  document.all.${name}_mw.style.display = "block"; ${name}_to_norm.style.display = "none";  ${name}_to_html.style.display = "block"; ${name}_mw.document.body.innerHTML = ${name}.value;' id="${name}_to_norm" style="DISPLAY: none">

MICRO
    
    return $ret;
};

# Миниворд #####################################################

$vtypes{'miniword'}{table_cre} = sub {
    
    return ' TEXT ';
    
};

$vtypes{'miniword'}{'aview'} = sub {

    my $name = shift;
    my $val = shift;
    
    $val =~ s/\"/\&quot;/g;
    $val =~ s/\</\&lt;/g;
    $val =~ s/\>/\&gt;/g;
    $val =~ s/\n/\\n/g;
    $val =~ s/\r//g;
    
    my $ret = <<MINI;
    
    
   <script language="javascript">
   <!--
   var oFCKeditor ;
   oFCKeditor = new FCKeditor('$name');
   oFCKeditor.ToolbarSet = 'JLite' ;
   oFCKeditor.Width  = '100%' ;
   oFCKeditor.Height = 350 ;
   oFCKeditor.imagesFolder = "structure" ;
   oFCKeditor.attachFolder = "structure" ;
   oFCKeditor.Value  = "$val";
   oFCKeditor.Create() ;
   //-->
   </script>

MINI
    
    return $ret;
};


# Временная метка ####################################################

$vtypes{timestamp}{table_cre} = sub {
    
    return ' TIMESTAMP ';
    
};

$vtypes{timestamp}{aview} = sub {};

$vtypes{timestamp}{aedit} = sub {};


# Время ####################################################

$vtypes{time}{table_cre} = sub {

	return ' TIME ';

};

$vtypes{time}{aview} = sub {

	my $name = shift;
	my $val = shift;
        my $ret;
        
        my @a = split(/\:/,$val);
        
        if($a[0] < 1){$a[0] = ''}
        if($a[1] < 1){$a[1] = ''}
        if($a[2] < 1){$a[2] = ''}
        
	$ret = "<input cols=4 style='WIDTH: 20px' type=text name='${name}_h' value=\"$a[0]\">";
        $ret .= "<input cols=4 style='WIDTH: 20px' type=text name='${name}_m' value=\"$a[1]\">";
        $ret .= "<input cols=6 style='WIDTH: 20px' type=text name='${name}_s' value=\"$a[2]\">";

	return $ret;

};

$vtypes{time}{aedit} = sub {

	my $name = shift;
	my $val;

        my $h = eml::param($name.'_h');
        my $m = eml::param($name.'_m');
        my $s = eml::param($name.'_s');

        $val = $h.':'.$m.':'.$s;

	return $val;

};

# Дата ####################################################

$vtypes{date}{table_cre} = sub {

	return ' DATE ';

};

$vtypes{date}{aview} = sub {

	my $name = shift;
	my $val = shift;
        my $ret;
        
        my @a = split(/\-/,$val);
        
        if($a[0] < 1){$a[0] = ''}
        if($a[1] < 1){$a[1] = ''}
        if($a[2] < 1){$a[2] = ''}
        
	$ret = "<input cols=4 style='WIDTH: 20px' type=text name='${name}_d' value=\"$a[2]\">";
        $ret .= "<input cols=4 style='WIDTH: 20px' type=text name='${name}_m' value=\"$a[1]\">";
        $ret .= "<input cols=6 style='WIDTH: 50px' type=text name='${name}_y' value=\"$a[0]\">";

	return $ret;

};

$vtypes{date}{aedit} = sub {

	my $name = shift;
	my $val;

        my $d = eml::param($name.'_d');
        my $m = eml::param($name.'_m');
        my $y = eml::param($name.'_y');

        $val = $y.'-'.$m.'-'.$d;

	return $val;

};


# Объект ###################################################

$vtypes{object}{table_cre} = sub {

	return ' INT ';

};

$vtypes{object}{aview} = sub {

	my $name = shift;
	my $val = shift;
	my $obj = shift;

	my %props = $obj->props();

	my $ret = "<a href=?class=".$props{$name}{class}."\&ID=".$obj->{$name}->{ID}.">".$obj->{$name}->name()."</a>";#$obj->{$name}->name()

	return $ret;

};

$vtypes{object}{aedit} = sub {

	my $name = shift;
	my $val = shift;
	my $obj = shift;

	return $obj->{$name};

};

$vtypes{object}{del} = sub {

	my $name = shift;
	my $val = shift;
	my $obj = shift;
        
        $obj->{$name}->del();
};

# Число ####################################################

$vtypes{int}{table_cre} = sub {

	return ' INT ';

};

$vtypes{int}{aview} = sub {

	my $name = shift;
	my $val = shift;

	my $ret = "<input width=50 type=text name='$name' value=\"$val\">";

	return $ret;

};

$vtypes{int}{aedit} = sub {

	my $name = shift;
	my $val = shift;

	$val =~ s/\D//g;
	if($val eq ''){ $val = 0; }

	return $val;

};

# Строка ####################################################

$vtypes{string}{table_cre} = sub {

	my %elem = %{$_[0]};

	return ' VARCHAR( '.$elem{length}.' ) ';

};

$vtypes{string}{aview} = sub {

	my $name = shift;
	my $val = shift;

	$val =~ s/\"/\&quot;/g;
	$val =~ s/\</\&lt;/g;
	$val =~ s/\>/\&gt;/g;

	my $ret = '<input class="winput" type=text name="'.$name.'" value="'.$val.'">';

	return $ret;

};

# Пароль ####################################################

$vtypes{password}{table_cre} = sub {

	my %elem = %{$_[0]};

	return ' VARCHAR( '.$elem{length}.' ) ';

};

$vtypes{password}{aview} = sub {

	my $name = shift;
	my $val = shift;

	$val =~ s/./*/g;

	my $ret = '<input class="winput" type=password name="'.$name.'" value="'.$val.'">';

	return $ret;

};


# Безразмерная строка ####################################################

$vtypes{vstring}{table_cre} = sub {

	my %elem = %{$_[0]};

	return ' TEXT ';

};

$vtypes{vstring}{aview} = sub {

	my $name = shift;
	my $val = shift;

	$val =~ s/\"/\&quot;/g;
	$val =~ s/\</\&lt;/g;
	$val =~ s/\>/\&gt;/g;

	my $ret = '<input class="winput" type=text name="'.$name.'" value="'.$val.'">';

	return $ret;

};

# Текст #####################################################

$vtypes{text}{table_cre} = sub {

	my %elem = %{$_[0]};

	return ' TEXT ';

};

$vtypes{text}{aview} = sub {

	my $name = shift;
	my $val = shift;

	$val =~ s/\"/\&quot;/g;
	$val =~ s/\</\&lt;/g;
	$val =~ s/\>/\&gt;/g;

	my $ret = '<textarea class="winput" cols=42 rows=15 name="'.$name.'">'.$val.'</textarea>';

	return $ret;

};

# Файл ######################################################

$vtypes{file}{table_cre} = sub {

	my %elem = %{$_[0]};

	return ' INT ';

};

$vtypes{file}{aview} = sub {

	my $name = shift;
	my $val = shift;
	my $obj = shift;
	my $file_href;

	if( $obj->{$name} ){ $file_href = "<a target=_new href='".$obj->file_href($name)."'>скачать</a>"; }

	my $ret = '<input class="winput" type=checkbox name="'.$name.'_todel"> - удалить. <input type=file cols=30 name="'.$name.'"> '.$file_href;

	return $ret;

};

$vtypes{file}{aedit} = sub {

	my $name = shift;
	my $val = shift;
	my $obj = shift;

	my %props = $obj->props();
	my $id = $obj->{ID};
	my ($buff,$len,$todel);
	if($id =~ m/\D/){ return 0; }

	my $fdir = '../htdocs/files/';

	#print "Saved: $fdir".ref($obj)."_${name}_$id".$props{$name}{ext};

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

$vtypes{file}{del} = sub {

	my $name = shift;
	my $val = shift;
	my $obj = shift;
        
	my %props = $obj->props();
	my $id = $obj->{ID};
        
        my $fdir = '../htdocs/files/';
        
        unlink( $fdir.ref($obj)."_${name}_$id".$props{$name}{ext} );
};

# Любой файл ######################################################

$vtypes{anyfile}{table_cre} = sub {

	my %elem = %{$_[0]};

	return ' VARCHAR(10) ';

};

$vtypes{anyfile}{aview} = sub {

	my $name = shift;
	my $val = shift;
	my $obj = shift;
	my $file_href;

	if( $obj->{$name} ){ $file_href = "<a target=_new href='".$obj->anyfile_href($name)."'>скачать</a>"; }

	my $ret = '<input type=checkbox name="'.$name.'_todel"> - удалить. <input type=file cols=30 name="'.$name.'"> '.$file_href;

	return $ret;

};

$vtypes{anyfile}{aedit} = sub {

	my $name = shift;
	my $val = shift;
	my $obj = shift;

	my %props = $obj->props();
	my $id = $obj->{ID};
	my ($buff,$len,$todel);
	if($id =~ m/\D/){ return 0; }

	my $fdir = '../htdocs/files/';

	#print "Saved: $fdir".ref($obj)."_${name}_$id".$props{$name}{ext};
        
	if($val){
                
		unlink( $fdir.ref($obj)."_${name}_$id".$obj->{$name} );
                
                $val =~ m/(\.\w+$)/;
                my $ext = $1;
                
                $ext =~ s/[^\w\.]//g;
                
                $obj->{$name} = $ext;
                
                #print $val;
                
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

$vtypes{anyfile}{del} = sub {

	my $name = shift;
	my $val = shift;
	my $obj = shift;
        
	my %props = $obj->props();
	my $id = $obj->{ID};
        
        my $fdir = '../htdocs/files/';
        
        unlink( $fdir.ref($obj)."_${name}_$id".$obj->{$name} );
};

# Галочка ###################################################

$vtypes{checkbox}{table_cre} = sub {

	my %elem = %{$_[0]};

	return ' INT ';

};

$vtypes{checkbox}{aview} = sub {

	my $name = shift;
	my $val = shift;

	if($val){$val = 'checked'}

	my $ret = "<input type=checkbox name='$name' $val>";

	return $ret;

};

$vtypes{checkbox}{aedit} = sub {

	my $name = shift;
	my $val = shift;

	if($val){$val = 1}

	return $val;

};

# Список ####################################################

$vtypes{select}{table_cre} = sub {
	
	my %elem = %{$_[0]};
	my %vars = %{ $elem{'variants'} };
	
	return " ENUM( '".join("', '",keys(%vars))."' )  ";
};

$vtypes{select}{aview} = sub {

	my $name = shift;
	my $val = shift;
	my $obj = shift;
	
	%props = $obj->props();
	%elem = %{ $props{$name} };
	
	my %vars = %{ $elem{'variants'} };
	my $var;
	my $ret = '<SELECT name="'.$name.'">';
	my $chkd = '';
	
	for $var (keys(%vars)){
	    
	    if($var eq $val){ $chkd = ' selected '; }else{ $chkd = ' '; }
	    $ret .= '<OPTION '.$chkd.' value="'.$var.'">'.$vars{$var}.'</OPTION>';
	}
	
	$ret .= '</SELECT>';
	
	return $ret;
};

$vtypes{select}{aedit} = sub {

	my $name = shift;
	my $val = shift;
	
	return $val;
};

# Переключатель #############################################

$vtypes{radio}{table_cre} = sub {

	return ' &lt;radio&gt; ';

};


1;
