# CMSBuilder © Леонов П. А., 2004-2006

package modUsers::User;
use strict qw(subs vars);
use utf8;

our @ISA = ('modUsers::UserMember','CMSBuilder::DBI::Object');

sub _cname {'Пользователь'}
sub _aview {qw/name email/}
sub _have_icon {1}

sub _props
{
	'name'		=> { 'type' => 'string', 'name' => 'Имя' },
	'email'		=> { 'type' => 'string', 'name' => 'E-Mail' },
}

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder::DBI;

sub table_cre
{
	my $class = shift;
	my $ret;
	
	$ret = $class->SUPER::table_cre(@_);
	
	$dbh->do('ALTER TABLE '.$class->object_tblname().' ADD INDEX ( `login` )');
	$dbh->do('ALTER TABLE '.$class->object_tblname().' ADD INDEX ( `pas` )');
	
	return $ret;
}

sub cre
{
	my $c = shift;
	
	my $o = $c->SUPER::cre(@_);
	
	$o->ochown($o, 'r' => 1);
}


1;