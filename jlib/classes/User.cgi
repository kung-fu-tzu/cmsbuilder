package User;
use strict qw(subs vars);

use vars '%props';
use vars '$name';
use vars '@ISA';
use vars '$page';
use vars '@aview';

$name = '������������';
@ISA = 'DBObject';
@aview = qw/name login pas icq email city/;
$page = '/page.ehtml';

%props = (
	
	'name'	  => { 'type' => 'string', 'length' => 50, 'name' => '���' },
	'login'	  => { 'type' => 'string', 'length' => 50, 'name' => '�����' },
	'pas'	  => { 'type' => 'password', 'length' => 50, 'name' => '������' },
	'sid'	  => { 'type' => 'string', 'length' => 20, 'name' => '����' },
	'icq'	  => { 'type' => 'int', 'length' => 15, 'name' => '#ICQ' },
	'email'	  => { 'type' => 'string', 'length' => 50, 'name' => 'E-Mail' },
	'city'	  => { 'type' => 'string', 'length' => 30, 'name' => '�����' },
);

sub creTABLE
{
	my $o = shift;
	my $str;
	
	$o->SUPER::creTABLE();
	
	$str = $eml::dbh->prepare('ALTER TABLE `dbo_'.ref($o).'` ADD INDEX ( `sid` )');
	$str->execute();
	
	$str = $eml::dbh->prepare('ALTER TABLE `dbo_'.ref($o).'` ADD INDEX ( `login` )');
	$str->execute();
}

sub new
{
	my $o = {};
	bless($o);

	#my $obj = $o->_construct(@_);
	#print $obj;
	#return $obj;
	return $o->_construct(@_);
}

sub DESTROY
{
	my $o = shift;
	$o->SUPER::DESTROY();
}

return 1;