package JDBI::VObject;
use strict qw(subs vars);
our @ISA = ('JDBI::Object');


###################################################################################################
# Методы заглушки
###################################################################################################

sub owner
{
	my $o = shift;
	return User->new(1);
}

sub check {}

sub enum { return 1; }

sub des_tree
{
	my $o = shift;
	print ref($o).' des_tree not defined';
}

sub name
{
	my $o = shift;
	my $ret;
	
	if($o->{'name'}){ return $o->{'name'} }
	
	return ${ref($o).'::name'}.' '.$o->{'ID'};
}


###################################################################################################
# Методы для реализации наследования Perl
###################################################################################################

sub new
{
	my $class = shift;
	
	my $o = {};
	bless($o,$class);
	
	$o->{'ID'} = 1;
	$o->{'OID'} = 1;
	
	return $o;
}

sub cre
{
	my $class = shift;
	
	return $class->new();
}


###################################################################################################
# Дополнительные методы
###################################################################################################

sub type { return 'VObject'; }

sub no_cache
{
	my $o = shift;
	return $o;
}

sub myurl
{
	my $o = shift;
	
	return ref($o).$o->{'ID'};
}

sub papa
{
	my $o = shift;
	
	if($o->{'PAPA_CLASS'} eq '' or $o->{'PAPA_ID'} < 1){ return undef; }
	
	return( $o->{'PAPA_CLASS'}->new($o->{'PAPA_ID'}) );
}

return 1;

