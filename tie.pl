#!/usr/bin/perl
use strict qw(subs vars);

my $var;
my $obj = Obj->new();

tie $obj->{'prop'}, 'Property', $obj, 'prop';


$obj->{'prop'} = 'hello';
print $obj->{'prop'};






package Property;

sub TIESCALAR
{
	my $c = shift;
	my($obj,$pname) = @_;
	my $o = {};
	
	$o->{'obj'} = $obj;
	$o->{'pname'} = $pname;
	
	bless($o,$c);
}

sub STORE
{
	my $o = shift;
	my $val = shift;
	
	my $meth = $o->{'pname'}.'_w';
	return $o->{'obj'}->$meth($val);
}

sub FETCH
{
	my $o = shift;
	
	my $meth = $o->{'pname'}.'_r';
	return $o->{'obj'}->$meth();
}


package Obj;/page/ModRoot1

sub new { return bless({},$_[0]); }

sub prop_w
{
	my $o = shift;
	my $val = shift;
	
	$o->{'prop_v'} = $val;
	
	print "prop_w($val)\n";
}

sub prop_r
{
	my $o = shift;
	
	print "prop_r() = ".$o->{'prop_v'}."\n";
	
	return $o->{'prop_v'};
}

1;