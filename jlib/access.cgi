
###################################################################################################
# Методы реализации разделения доступа
###################################################################################################

use vars '%access_types';
#use vars '@access_words';

%access_types = (
		'r' => 'Чтение',
		'e' => 'Изменение',
		'a' => 'Добавление элементов',
		'с' => 'Смена разрешений',
		'x' => 'Просмотр каталога'
		);

#@access_words = qw/all owner/;

sub access_get
{
	my $o = shift;
	my %membs;
	
	my $str = $eml::dbh->prepare('SELECT memb,code FROM `access` WHERE memb in (?,?,?,?)');
	$str->execute('all','owner',$eml::g_group->myurl(),$eml::g_user->myurl());
	
	my $res;
	for $res ( $str->fetchrow_hashref('NAME_lc') ){ $membs{$res->{'memb'}} = $res->{'code'} }
	
	$o->{'_access_code'} = '';
	
	if(exists $membs{$eml::g_user->myurl()}){ $o->{'_access_code'} = $membs{$eml::g_user->myurl()}; return; }
	if(exists $membs{'owner'} and $eml::g_user->{'ID'} == $o->{'OID'}){ $o->{'_access_code'} = $membs{'owner'}; return; }
	
	if(exists $membs{$eml::g_group->myurl()}){ $o->{'_access_code'} = $membs{$eml::g_group->myurl()}; return; }
	if(exists $membs{'all'}){ $o->{'_access_code'} = $membs{'all'}; return; }
	
	my $papa = %o->papa();
	
	if(!$papa){ return; }
	if(!$papa->{'_access_code'}){ $papa->access_get(); }
	
	return $papa->{'_access_code'};
}

sub access
{
	my $o = shift;
	my $type = shift;
	
	if(length($type) != 1){ return 0 }
	
	if($eml::g_group->{'root'}){ return 1 }
	
	
	if(!$o->{'_access_code'}){ $o->access_get() }
	
	if( index($o->{'_access_code'},$type) >= 0 ){ return 1; }
	
	return 0;
}

sub access_creTABLE
{
	my $sql = 'CREATE TABLE IF NOT EXISTS `access` ( '."\n";
	$sql .= '`ID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY , ';
	$sql .= '`url` VARCHAR(50) NOT NULL, ';
	$sql .= '`memb` VARCHAR(50) DEFAULT \'\' NOT NULL, ';
	$sql .= '`code` VARCHAR(20) DEFAULT \'\' NOT NULL, ';
	$sql .= 'INDEX ( `memb` ), INDEX ( `url` ) )';

	my $str = $eml::dbh->prepare($sql);
	$str->execute();
}





1;

