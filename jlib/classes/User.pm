# (ñ) Ëåîíîâ Ï.À., 2005

package User;
use strict qw(subs vars);
our @ISA = 'JDBI::Object';

sub _cname {'Ïîëüçîâàòåëü'}
sub _aview {qw/name login pas icq email city/}

sub _props
{
	'name'		=> { 'type' => 'string', 'length' => 50, 'name' => 'Èìÿ' },
	'login'		=> { 'type' => 'string', 'length' => 50, 'name' => 'Ëîãèí' },
	'pas'		=> { 'type' => 'password', 'length' => 50, 'name' => 'Ïàğîëü' },
	'sid'		=> { 'type' => 'string', 'length' => 32, 'name' => 'Êëş÷' },
	'icq'		=> { 'type' => 'int', 'name' => '#ICQ' },
	'email'		=> { 'type' => 'string', 'length' => 50, 'name' => 'E-Mail' },
	'city'		=> { 'type' => 'string', 'length' => 30, 'name' => 'Ãîğîä' }
}

#-------------------------------------------------------------------------------


sub table_cre
{
	my $class = shift;
	my $ret;
	
	$ret = $class->SUPER::table_cre(@_);
	
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

1;