
# ����� ####################################################

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

# ���� ####################################################

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


# ������ ###################################################

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

# ����� ####################################################

$vtypes{int}{table_cre} = sub {

	return ' INT ';

};

$vtypes{int}{aview} = sub {

	my $name = shift;
	my $val = shift;

	my $ret = "<input cols=6 type=text name='$name' value=\"$val\">";

	return $ret;

};

$vtypes{int}{aedit} = sub {

	my $name = shift;
	my $val = shift;

	$val =~ s/\D//g;
	if($val eq ''){ $val = 0; }

	return $val;

};

# ������ ####################################################

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

	my $ret = "<input cols=60 type=text name='$name' value=\"$val\">";

	return $ret;

};

# ����� #####################################################

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

	my $ret = "<textarea cols=42 rows=15 name='$name'>$val</textarea>";

	return $ret;

};

# ���� ######################################################

$vtypes{file}{table_cre} = sub {

	my %elem = %{$_[0]};

	return ' INT ';

};

$vtypes{file}{aview} = sub {

	my $name = shift;
	my $val = shift;
	my $obj = shift;
	my $file_href;

	if( $obj->{$name} ){ $file_href = "<a target=_new href='".$obj->file_href($name)."'>�������</a>"; }

	my $ret = "<input type=checkbox name='${name}_todel'> - �������. <input type=file cols=30 name='$name'> $file_href";

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

# ����� ���� ######################################################

$vtypes{anyfile}{table_cre} = sub {

	my %elem = %{$_[0]};

	return ' VARCHAR(10) ';

};

$vtypes{anyfile}{aview} = sub {

	my $name = shift;
	my $val = shift;
	my $obj = shift;
	my $file_href;

	if( $obj->{$name} ){ $file_href = "<a target=_new href='".$obj->anyfile_href($name)."'>�������</a>"; }

	my $ret = "<input type=checkbox name='${name}_todel'> - �������. <input type=file cols=30 name='$name'> $file_href";

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

# ������� ###################################################

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

# ������ ####################################################

$vtypes{select}{table_cre} = sub {

	return ' &lt;select&gt; ';

};

# ������������� #############################################

$vtypes{radio}{table_cre} = sub {

	return ' &lt;radio&gt; ';

};


1;
