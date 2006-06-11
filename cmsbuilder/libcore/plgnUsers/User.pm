# (с) Леонов П.А., 2005

package User;
use strict qw(subs vars);
our @ISA = ('plgnUsers::UserMember','CMSBuilder::DBI::Object');

sub _cname {'Пользователь'}
sub _aview {qw/name email/}
sub _have_icon {1}

sub _props
{
	'name'		=> { 'type' => 'string', 'name' => 'Имя' },
	'email'		=> { 'type' => 'string', 'name' => 'E-Mail' },
}

#-------------------------------------------------------------------------------


sub table_cre
{
	my $class = shift;
	my $ret;
	
	$ret = $class->SUPER::table_cre(@_);
	
	$CMSBuilder::DBI::dbh->do('ALTER TABLE '.$class->object_tblname().' ADD INDEX ( `login` )');
	$CMSBuilder::DBI::dbh->do('ALTER TABLE '.$class->object_tblname().' ADD INDEX ( `pas` )');
	
	return $ret;
}



1;