#!/usr/bin/perl
use strict;
use utf8;
BEGIN {exit 254 if $^O =~ /Win32/}

use Test::Simple tests => 4;

use CMSBuilder;
use CMSBuilder::Config qw($cfg);
BEGIN { CMSBuilder->configure }
use CMSBuilder::Daemon;


#use warnings 'CMSBuilder::Daemon';
$cfg->{daemon}->{errorlog} = undef;
$cfg->{daemon}->{procname} = 'daemon-performance';


#———————————————————————————————————————————————————————————————————————————————

system('killall -9 daemon-performance');

@Test::Daemon::perf::ISA = qw(CMSBuilder::Daemon);
sub Test::Daemon::perf::daemon_accept
{
	my $c = shift;
	my $clnt = shift;
	
	#sleep 50;
	1 while 1;
}

ok my $d = Test::Daemon::perf->new, 'perf new';
ok $d->start, 'perf start';
sleep 1;

my @all;

push @all, $d->socket for 1..30;
push @all, $d->socket for 1..30;
push @all, $d->socket for 1..30;
sleep 1;

ok $d->hard_quit, 'perf hard_quit';
sleep 1;

ok ! $d->kill, 'perf !kill after';

#———————————————————————————————————————————————————————————————————————————————

system('killall -9 daemon-performance');


1;