
# Дата ####################################################

$vtypes{date}{table_cre} = sub {

	return ' DATE ';

};

$vtypes{date}{aview} = sub {

	my $name = shift;
	my $val = shift;
        my $ret;
        
        my @a = split(/\-/,$val);
        
	$ret = "<input cols=4 type=text name='${name}_d' value=\"$a[2]\">";
        $ret .= "<input cols=4 type=text name='${name}_m' value=\"$a[1]\">";
        $ret .= "<input cols=6 type=text name='${name}_y' value=\"$a[0]\">";

	return $ret;

};

$vtypes{date}{aedit} = sub {

	my $name = shift;
	my $val;

        my $d = main::param($name.'_d');
        my $m = main::param($name.'_m');
        my $y = main::param($name.'_y');

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

	my $ret = "<a $EML::dbo::emlh href=?class=".$props{$name}{class}."\&ID=".$obj->{$name}->{ID}.">".$obj->{$name}->name()."</a>";#$obj->{$name}->name()

	return $ret;

};

$vtypes{object}{aedit} = sub {

	my $name = shift;
	my $val = shift;
	my $obj = shift;

	return $obj->{$name};

};

# Число ####################################################

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

	my $ret = "<input cols=60 type=text name='$name' value=\"$val\">";

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

	my $ret = "<textarea cols=42 rows=15 name='$name'>$val</textarea>";

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

	my $ret = "<input type=checkbox name='${name}_todel'> - удалить. <input type=file cols=30 name='$name'> $file_href";

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

	my $fdir = '../www/files/';

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
		$todel = main::param($name.'_todel');

		if($todel) {
			unlink( $fdir.ref($obj)."_${name}_$id".$props{$name}{ext} );
			return 0;
		}		
	}

	return $obj->{$name};

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

# Список ####################################################

$vtypes{select}{table_cre} = sub {

	return ' &lt;select&gt; ';

};

# Переключатель #############################################

$vtypes{radio}{table_cre} = sub {

	return ' &lt;radio&gt; ';

};


1;
