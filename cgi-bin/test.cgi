#!/usr/bin/perl
use strict qw(subs vars);

use lib 'E:/home/engine/jlib';

print "Content-type: text/html; charset=windows-1251\n\n";

use JDBI;
use Classes::Elem;
use Classes::User;

JDBI::init();
JDBI::connect('DBI:mysql:engine','root','pas');
JDBI::dousers(0);

#JDBI::creTABLE('User');
#JDBI::creTABLE('Elem');

my $to = Elem->new(1);
$to->admin_view();
#$to->{'name'} = 'Pete';

print 'OK';











