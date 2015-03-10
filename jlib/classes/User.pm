package User;
use strict qw(subs vars);

our $name = '������������';
our @ISA = 'JDBI::Object';
our @aview = qw/name login pas icq email city/;
our $page = '/page';
our $icon = 1;

our %props = (
	'name'		=> { 'type' => 'string', 'length' => 50, 'name' => '���' },
	'login'		=> { 'type' => 'string', 'length' => 50, 'name' => '�����' },
	'pas'		=> { 'type' => 'password', 'length' => 50, 'name' => '������' },
	'sid'		=> { 'type' => 'string', 'length' => 32, 'name' => '����' },
	'icq'		=> { 'type' => 'int', 'name' => '#ICQ' },
	'email'		=> { 'type' => 'string', 'length' => 50, 'name' => 'E-Mail' },
	'city'		=> { 'type' => 'string', 'length' => 30, 'name' => '�����' }
);

sub setup_fix_table
{
	my $class = shift;
	my $ret;
	
	$ret = $class->SUPER::setup_fix_table(@_);
	
	$JDBI::dbh->do('ALTER TABLE `dbo_'.$class.'` ADD INDEX ( `sid` )');
	$JDBI::dbh->do('ALTER TABLE `dbo_'.$class.'` ADD INDEX ( `login` )');
	$JDBI::dbh->do('ALTER TABLE `dbo_'.$class.'` ADD INDEX ( `pas` )');
	
	return $ret;
}

sub save
{
	my $o = shift;
	my($pas,$ret);
	
	$pas = $o->{'pas'};
	if($o->{'pas'}){ $o->{'pas'} = JDBI->MD5($o->{'pas'}); }
	$ret = $o->SUPER::save(@_);
	$o->{'pas'} = $pas;
	
	return $ret;
}

return 1;