#!/usr/bin/perl
use strict;
use utf8;
BEGIN {exit 254 if $^O =~ /Win32/}
use Test::Simple tests => 15;

use CMSBuilder;
use CMSBuilder::Utils;

CMSBuilder->configure;
require CMSBuilder::Daemon::cgi;


*CMSBuilder::Daemon::cgi::daemon_process = sub
{
	my $o = shift;
	
	print 'OK';
};

ok my $d = CMSBuilder::Daemon::cgi->new, 'new daemon handler';
ok my $s = $d->client_socket, 'client_socket';
ok close $s, 'close socket';
sleep 1;
ok $d->ping, 'ping';

ok my $out = catch_out { $d->client_proxy }, 'out';
ok $out eq 'OK', 'out eq OK';


ok $d->soft_quit, 'soft_quit';
sleep 2;
ok ! $d->ping, 'ping';
ok ! $d->kill, 'kill';


#–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––


ok $d = CMSBuilder::Daemon::cgi->new, 'new daemon handler 2';

*CMSBuilder::Daemon::cgi::daemon_process = sub
{
	my $o = shift;
	
	my @in = <STDIN>;
	warn @in;
	print @in, 'OK';
};



my $buff = "123\n";
close STDIN;
open STDIN, '<', \$buff;

#my $res = <STDIN>;
#warn $res;

$ENV{CONTENT_LENGTH}  = length $buff;

ok my $out2 = catch_out { $d->client_proxy }, 'out2';
warn $out2;
ok $out2 eq "123\nOK", 'out2 eq 123\nOK';

#die $out;

ok $d->soft_quit, 'soft_quit2';
sleep 1;
ok ! $d->ping, 'ping2';
ok ! $d->kill, 'kill2';

1;