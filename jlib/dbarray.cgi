package DBArray;
@ISA = 'DBObject';
use strict qw(subs vars);

sub insert
{
	my $o = shift;

	my $nid = $o->SUPER::insert();;

	my $sql = 'CREATE TABLE `arr_'.ref($o).'_'.$nid.'` ( '."\n";
	$sql .= '`num` INT NOT NULL AUTO_INCREMENT PRIMARY KEY , ';
	$sql .= '`ID` INT DEFAULT \'-1\' NOT NULL, ';
	$sql .= '`CLASS` VARCHAR(20) NOT NULL )';

	my $str = $main::dbh->prepare($sql);
	$str->execute();

	return $nid;

}

sub len
{
	my $o = shift;

	my $str = $main::dbh->prepare('SELECT COUNT(*) AS LEN FROM `arr_'.ref($o).'_'.$o->{ID}.'`');
	$str->execute();
	
	my $res = $str->fetchrow_hashref('NAME_uc');
	
	return $res->{'LEN'};
}

sub elem
{
	my $o = shift;
	my $eid = shift;
	
	my $sql = 'SELECT * FROM `arr_'.ref($o).'_'.$o->{ID}.'` WHERE num = ? LIMIT 1';

	my $str = $main::dbh->prepare($sql);
	$str->execute($eid);
	
	my $res = $str->fetchrow_hashref('NAME_uc');
	
	return &{ 'main::'.$res->{'CLASS'}.'::new' }($res->{ID});
	
}

sub addelem
{
	my $o = shift;
	my $class = shift;
	
	my $nob = &{ 'main::'.$class.'::new' }('cre');
	$nob->{PAPA_ID} = $o->{ID};
	$nob->{PAPA_CLASS} = ref($o);
	
	my $str = 'INSERT INTO `arr_'.ref($o).'_'.$o->{ID}.'` (ID,CLASS) VALUES (?,?)';
	$str = $main::dbh->prepare($str);
	$str->execute($nob->{ID},$class);
	
	$o->sortT();
}

sub delelem
{
	my $o = shift;
	my $eid = shift;
	
	my $ob = $o->elem($eid);
	$ob->{PAPA_ID} = -1;
	$ob->{PAPA_CLASS} = '';
	$ob->del();
	
	my $sql = 'DELETE FROM `arr_'.ref($o).'_'.$o->{ID}.'` WHERE num = ?';
	my $str = $main::dbh->prepare($sql);
	$str->execute($eid);

	$o->sortT();
}

sub del
{
	my $o = shift;
	my $i;
	my $len = $o->len();

	for($i=1;$i<=$len;$i++){
		
		$o->delelem(1);
		
	}
	
	my $str = $main::dbh->prepare('DROP TABLE `arr_'.ref($o).'_'.$o->{ID}.'`');
	$str->execute();
	
	$o->SUPER::del();
}

sub aview
{
	my $o = shift;
	my $e;
	my $i;

	$o->SUPER::aview();

	print '<br><hr align=left style="WIDTH: 200px">';

	for($i=1;$i<=$o->len();$i++){
		
		$e = $o->elem($i);
		print '<br>';
		print "<a onclick='return doDel()' href=?ID=".$o->{ID}."&enum=$i&act=dele><img border=0 src=x.gif></a>";
		print "<a href=?ID=".$o->{ID}."&enum=$i&act=eup><img border=0 src=up.gif></a>";
		print "<a href=?ID=".$o->{ID}."&enum=$i&act=edown><img border=0 src=down.gif></a>";
		print '&nbsp;&nbsp;';
		print '<a '.$EML::dbo::emlh.' href=?class='.ref($e).'&ID='.$e->{ID}.'>',$e->name(),'</a>';
	}
	
	print '<br><br>';
	
	my $c;
	
	print '<form action=?>';
	print '<input type="hidden" name="ID" value="',$o->{ID},'">',"\n";
	print '<input type="hidden" name="act" value="adde">',"\n";

	print '<select name=cname><OPTION selected></OPTION>';
	for $c (@eml::dbos){
		
		print "<OPTION value='$c'>${'main::'.$c.'::name'}</OPTION>";
	}
	print '</select><input type=submit value="Добавить"></form>';
	print '<br><br>';
}

sub DESTROY
{
	my $o = shift;
	$o->SUPER::DESTROY();
}

sub upelem
{
	my $o = shift;
	my $num = shift;
	if($num == 1){ return; }
	
	my $table = 'arr_'.ref($o).'_'.$o->{ID};
	
	my $str = $main::dbh->prepare( "UPDATE `$table` SET `num` = ? WHERE `num` = ?" );
	$str->execute(99999,$num-1);
	$str->execute($num-1,$num);
	$str->execute($num,99999);
	
	$o->sortT();
}

sub downelem
{
	my $o = shift;
	my $num = shift;
	if($num == $o->len()){ return; }
	
	my $table = 'arr_'.ref($o).'_'.$o->{ID};
	
	my $str = $main::dbh->prepare( "UPDATE `$table` SET `num` = ? WHERE `num` = ?" );
	$str->execute(99999,$num+1);
	$str->execute($num+1,$num);
	$str->execute($num,99999);
	
	$o->sortT();
}

sub sortT
{
	my $o = shift;
	my($i,$str,$str2,$num,$table);
	
	$table = 'arr_'.ref($o).'_'.$o->{ID};
	
	$str = $main::dbh->prepare( "ALTER TABLE `$table` ORDER BY `num`" );
	$str->execute();
	
	$str = $main::dbh->prepare( "SELECT num FROM `$table`" );
	$str->execute();
	
	$str2 = $main::dbh->prepare( "UPDATE `$table` SET `num` = ? WHERE `num` = ?" );
	
	$i = 1;
	while(($num) = $str->fetchrow_array()){
	
	    $str2->execute($i,$num);
	    $i++;
	}

}

return 1;