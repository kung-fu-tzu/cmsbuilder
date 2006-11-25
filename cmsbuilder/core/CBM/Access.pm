# CMSBuilder © Леонов П. А., 2005-2006

package CBM::Access;
use strict;
use utf8;

use CMSBuilder;

use Exporter;
our @EXPORT =
qw(
	$AC_READ $AC_WRITE $AC_ADD $AC_CHMOD $AC_CHOWN
	%access_types %access_type2bin
);

our ($AC_READ,$AC_WRITE,$AC_ADD,$AC_CHMOD,,$AC_CHOWN) = (1,2,4,8,16,32);

our %access_types =
(
	$AC_READ => 'Чтение',
	$AC_WRITE => 'Редактирование',
	$AC_ADD => 'Добавление&nbsp;элементов',
	$AC_CHMOD => 'Смена&nbsp;разрешений',
	#$AC_EXEC => 'Доступ&nbsp;ко&nbsp;вложенным',
	$AC_CHOWN => 'Изменять&nbsp;владельца',
);

our %access_type2bin =
(
	r => $AC_READ,
	w => $AC_WRITE,
	a => $AC_ADD,
	c => $AC_CHMOD,
	#x => $AC_EXEC,
	o => $AC_CHOWN,
);

our @ISA = qw(CMSBuilder::Module Exporter);
sub class_name {'Разделение доступа'}

sub mod_load
{
	#unshift @CMSBuilder::Object::ISA,'CBM::Access::Object';
	
	#cmsb_event_reg('admin_view_additional',\&admin_additional);
}

sub mod_install
{
	my ($dbd,$u,$p) = ($CMSBuilder::Config::mysql_data_source,$CMSBuilder::Config::mysql_user,$CMSBuilder::Config::mysql_pas);
	my $dbh = DBI->connect($dbd,$u,$p);
	
	my $sql =
	"
	CREATE TABLE IF NOT EXISTS `${CMSBuilder::Config::table_name_pfx}access`
	(
		`ID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
		`url` VARCHAR(50) NOT NULL,
		`memb` VARCHAR(50) DEFAULT '' NOT NULL,
		`code` INT DEFAULT 0 NOT NULL,
		INDEX ( `memb` ), INDEX ( `url` )
	)
	";
	
	return $dbh->do($sql);
}

sub admin_additional
{
	my $o = shift;
	
	print '<tr><td valign="top">Вам&nbsp;разрешено:</td><td valign="top">',$o->access_print(),'</td></tr>';
}


1;