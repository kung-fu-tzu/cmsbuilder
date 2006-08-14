# CMSBuilder © Леонов П. А., 2005-2006

package CMSBuilder::DBI;
use strict qw(subs vars);
use utf8;

our @ISA = qw(CMSBuilder::Module Exporter);

sub _cname {'Интерфейс к MySQL'}

use DBI;
use Carp;
use Exporter;

our @EXPORT = qw($dbh);

#———————————————————————————————————————————————————————————————————————————————

# а реквайрим потому, что многие из этих файлов
# импортируют переменную $dbh из этого (CMSBuilder::DBI)
require CMSBuilder::DBI::VType;

require CMSBuilder::DBI::Object::OBase;
require CMSBuilder::DBI::Object::ONoBase;
require CMSBuilder::DBI::Object::OCore;
require CMSBuilder::DBI::Object::OAdmin;
require CMSBuilder::DBI::Object;

require CMSBuilder::DBI::Array::ABase;
require CMSBuilder::DBI::Array::ACore;
require CMSBuilder::DBI::Array::AAdmin;
require CMSBuilder::DBI::FilteredArray;
require CMSBuilder::DBI::Array;

require CMSBuilder::DBI::RPC;

require CMSBuilder::Utils;

#———————————————————————————————————————————————————————————————————————————————

our
(
	$dbh,
);

#————————————————————————————— Интерфейсные функции ————————————————————————————

sub mod_init
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

sub mod_destruct
{
	$dbh->disconnect() unless $CMSBuilder::Config::dbi_keepalive;
}

#———————————————————————————————— Базовые функции ——————————————————————————————

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
	
	$dbh->{'HandleError'} = sub	{ local $Carp::CarpLevel = 1; croak($_[0]);	};
	$dbh->{'RaiseError'} = 1;
}

sub fix_connection
{
	my $c = shift;
	
	eval { $dbh->do('SELECT NOW()'); };
	if($@){ $c->connect(); warn 'DBI reconnected'; }
}

#—————————————————————————————— Дополнительные функции —————————————————————————

sub access_creTABLE()
{
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

sub table_exists
{
	my $tn = shift;
	
	$tn =~ s/.*\.//;
	$tn =~ s/\`//g;
	
	unless($tn || $dbh){ return 0; }
	
	return $dbh->selectrow_array('SHOW TABLES LIKE \''.$tn.'\'')?1:0;
}

1;