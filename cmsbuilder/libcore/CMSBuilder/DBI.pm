# (с) Леонов П.А., 2005

package CMSBuilder::DBI;
use strict qw(subs vars);
our @ISA = 'CMSBuilder::Plugin';

use DBI;
use Carp;

use CMSBuilder::DBI::VType;

use CMSBuilder::DBI::Object::OBase;
use CMSBuilder::DBI::Object::ONoBase;
use CMSBuilder::DBI::Object::OCore;
use CMSBuilder::DBI::Object::OAdmin;
use CMSBuilder::DBI::Object;

use CMSBuilder::DBI::Array::ABase;
use CMSBuilder::DBI::Array::ACore;
use CMSBuilder::DBI::Array::AAdmin;
use CMSBuilder::DBI::FilteredArray;
use CMSBuilder::DBI::Array;

use CMSBuilder::DBI::RPC;
use CMSBuilder::DBI::EventsInterface;
use CMSBuilder::DBI::CMS;
use CMSBuilder::DBI::Module;
use CMSBuilder::DBI::SimpleModule;
use CMSBuilder::DBI::TreeModule;

use CMSBuilder::Utils;

#-------------------------------------------------------------------------------


################################################################################
# Базовые переменные
################################################################################

our
(
	$dbh,@vtypes,%cmenus,
);


################################################################################
# Интерфейсные функции
################################################################################

sub plgn_load
{
	# Инклудим виртуальные типы ядра
	for my $vt (listpms($CMSBuilder::Config::path_libcore.'/VTypes'))
	{
		require $CMSBuilder::Config::path_libcore.'/VTypes/'.$vt.'.pm';
		push @vtypes, $vt;
	}
	
	# Инклудим виртуальные типы пользователя
	for my $vt (listpms($CMSBuilder::Config::path_libsite.'/VTypes'))
	{
		require $CMSBuilder::Config::path_libsite.'/VTypes/'.$vt.'.pm';
		push @vtypes, $vt;
	}
}

sub plgn_init
{
	my $c = shift;
	
	if($CMSBuilder::Config::dbi_keepalive && $dbh)
	{
		$c->fix_connection();
	}
	else
	{
		$c->connect();
	}
}

sub plgn_destruct
{
	$dbh->disconnect() unless $CMSBuilder::Config::dbi_keepalive;
}


################################################################################
# Базовые функции
################################################################################

sub connect
{
	my $c = shift;
	my($dbd,$u,$p);
	
	if(@_)
	{
		($dbd,$u,$p) = @_;
	}
	else
	{
		($dbd,$u,$p) = ($CMSBuilder::Config::mysql_data_source,$CMSBuilder::Config::mysql_user,$CMSBuilder::Config::mysql_pas);
	}
	
	$dbh = DBI->connect($dbd,$u,$p);
	
	if($CMSBuilder::Config::dbi_inactivedestroy)
	{
		$dbh->{'InactiveDestroy'} = 1;
	}
	
	if($CMSBuilder::Config::mysql_charset)
	{
		$dbh->do('SET character_set_client=\''.$CMSBuilder::Config::mysql_charset.'\'');
		$dbh->do('SET character_set_results=\''.$CMSBuilder::Config::mysql_charset.'\'');
	}
	
	if($CMSBuilder::Config::mysql_colcon)
	{
		$dbh->do('SET collation_connection=\''.$CMSBuilder::Config::mysql_colcon.'\'');
	}
	
	$dbh->{'HandleError'} = sub	{ croak($_[0]);	};
	$dbh->{'RaiseError'} = 1;
}

sub fix_connection
{
	my $c = shift;
	
	eval { $dbh->do('SELECT NOW()'); };
	if($@){ $c->connect(); warn 'DBI reconnected'; }
}

################################################################################
# Дополнительные функции
################################################################################

sub access_creTABLE()
{
	my $sql =
	'
	CREATE TABLE IF NOT EXISTS `access`
	(
		`ID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
		`url` VARCHAR(50) NOT NULL,
		`memb` VARCHAR(50) DEFAULT \'\' NOT NULL,
		`code` INT DEFAULT 0 NOT NULL,
		INDEX ( `memb` ), INDEX ( `url` )
	)
	';
	
	return $dbh->do($sql);
}

sub table_exists
{
	my $tn = shift;
	
	$tn =~ s/.*\.//;
	$tn =~ s/\`//g;
	
	unless($tn || $dbh){ return 0; }
	
	return $dbh->selectrow_array('SHOW TABLES LIKE \''.$tn.'\'')?1:0;
}

1;