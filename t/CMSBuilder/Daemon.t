#!/usr/bin/perl
use strict;
use utf8;
BEGIN {exit 254 if $^O =~ /Win32/}
#BEGIN {exit 0}
use Test::Simple tests => 52;

use CMSBuilder;
use CMSBuilder::Config qw($cfg);
BEGIN { CMSBuilder->configure }
use CMSBuilder::Daemon;


#use warnings 'CMSBuilder::Daemon';
$cfg->{daemon}->{errorlog} = './Daemon.t.error.log';
$cfg->{daemon}->{procname} = undef;

# удалим лог
unlink $cfg->{daemon}->{errorlog};

$| = 1;


@Test::Daemon::ok::ISA = qw(CMSBuilder::Daemon);
sub Test::Daemon::ok::daemon_listen { exit 0 }

@Test::Daemon::bad::ISA = qw(CMSBuilder::Daemon);
sub Test::Daemon::bad::daemon_listen { exit 4 }

@Test::Daemon::die::ISA = qw(CMSBuilder::Daemon);
sub Test::Daemon::die::daemon_listen { die 'daemon_listen wants to die' }

@Test::Daemon::run::ISA = qw(CMSBuilder::Daemon);


# нормально завершается
ok (Test::Daemon::ok->new->start, 'start');
wait;
ok ! $?;

# нормально завершается с кодом
ok (Test::Daemon::bad->new->start, 'start');
wait;
ok $?;

# завершается исключением
ok (Test::Daemon::die->new->start, 'start');
wait;
ok $?;



#———————————————————————————————————————————————————————————————————————————————



#$SIG{CHLD} = sub { die 'SIGCHLD'; };
$SIG{CHLD} = 'IGNORE';


my $d = Test::Daemon::run->new;

ok (! $d->ping, "ping-0: $!");
ok my $dpid = $d->start, 'start';
ok ! $d->start, 'start again';
sleep 1;
ok ($d->ping, "ping-1: $!");
ok ($d->sig('USR1'), "sig('USR1'): $!");
ok ($d->sig('USR2'), "sig('USR2'): $!");
ok ($d->soft_quit, 'soft_quit');
sleep 1;
ok (! $d->ping, "ping-2: $!");
ok ! $d->kill, '!kill after';



#———————————————————————————————————————————————————————————————————————————————



# маленький сервачок
my $daemon_loop = 1;
my $daemon_restart = 0;

@Test::Daemon::socket::ISA = qw(CMSBuilder::Daemon);
sub Test::Daemon::socket::daemon_accept
{
	my $c = shift;
	my $clnt = shift;
	
	my $str = <$clnt>;
	
	print $clnt 123 . $str;
}

$SIG{CHLD} = 'IGNORE';

$d = Test::Daemon::socket->new;

# тут еще не должно быть сокета
ok ! $d->socket, 'not socket';

# потестим передачу даннных
ok ($d->start, 'start-s');
sleep 1;
ok ($d->ping, "ping-s-1: $!");
sleep 1;

ok my $s = $d->socket, 'socket';
my $str = 'OK';
ok print $s "$str\n";
ok join('',<$s>) eq "123$str\n", 'read from socket';
ok (close $s, 'close socket');

ok ($d->soft_quit, 'soft_quit-s');
sleep 1;
ok (! $d->ping, "ping-s-2: $!");
ok ! $d->kill, '!kill after2';



#———————————————————————————————————————————————————————————————————————————————
# hard_quit

@Test::Daemon::hard_quit::ISA = qw(CMSBuilder::Daemon);
sub Test::Daemon::hard_quit::daemon_accept
{
	my $c = shift;
	my $clnt = shift;
	
	#sleep 50;
	sleep 2 while 1;
}

ok $d = Test::Daemon::hard_quit->new, 'hard_quit new';
ok $d->start, 'hard_quit start';

sleep 1;

ok my $s1h = $d->socket, 'hard_quit s1h';
ok my $s2h = $d->socket, 'hard_quit s2h';
ok my $s3h = $d->socket, 'hard_quit s3h';
sleep 1;



ok print($s1h 'Hi!'), 'hard_quit print s1h';
ok print($s2h 'Hi!'), 'hard_quit print s2h';
ok print($s3h 'Hi!'), 'hard_quit print s3h';

ok $d->hard_quit, 'hard_quit hard_quit';

sleep 1;

ok ! print($s1h 'Hi!'), 'hard_quit !print s1h';
ok ! print($s2h 'Hi!'), 'hard_quit !print s2h';
ok ! print($s3h 'Hi!'), 'hard_quit !print s3h';

ok ! $d->kill, 'hard_quit !kill';


#———————————————————————————————————————————————————————————————————————————————
# soft_quit

@Test::Daemon::soft_quit::ISA = qw(CMSBuilder::Daemon);
sub Test::Daemon::soft_quit::daemon_accept
{
	my $c = shift;
	my $clnt = shift;
	
	#sleep 50;
	sleep 2 while 1;
}

ok $d = Test::Daemon::soft_quit->new, 'soft_quit new';
ok $d->start, 'soft_quit start';
sleep 1;

#BEGIN { no strict; *{'soft–quit'} = sub {warn '123'} }
#${\'soft–quit'}->();

ok my $s1s = $d->socket, 'soft_quit s1s';
ok my $s2s = $d->socket, 'soft_quit s2s';
ok my $s3s = $d->socket, 'soft_quit s3s';
sleep 1;


ok print($s1s 'Hi!'), 'soft_quit print s1s';
ok print($s2s 'Hi!'), 'soft_quit print s2s';
ok print($s3s 'Hi!'), 'soft_quit print s3s';

ok $d->soft_quit, 'soft_quit soft_quit';
sleep 1;

ok print($s1s 'Hi!'), 'soft_quit print s1s-2';
ok print($s2s 'Hi!'), 'soft_quit print s2s-2';
ok print($s3s 'Hi!'), 'soft_quit print s3s-2';

ok $d->hard_quit, 'soft_quit hard_quit';
sleep 1;

ok ! $d->kill, 'soft_quit !kill';


#———————————————————————————————————————————————————————————————————————————————

1;