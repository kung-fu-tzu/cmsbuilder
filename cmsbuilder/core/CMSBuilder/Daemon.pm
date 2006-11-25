# (с) Леонов П.А., 2005

package CMSBuilder::Daemon;
use strict;
use utf8;

use warnings::register;

use Socket;
use POSIX qw(:sys_wait_h setsid);

use CMSBuilder::Utils;
use CMSBuilder::SysUtils 'VIRTUAL';
use CMSBuilder::Config qw($cfg);


sub new { my $c = shift; return bless {$c->defaults, @_}, $c }

sub defaults
{
	die '$cfg->{daemon} undefined' unless $cfg->{daemon};
	return
	(
		config => $cfg->{daemon},
		daemon_loop => 1,
		one_instance => 1
	)
}

sub config
{
	return $_[0]->{config};
}


sub start
{
	my $o = shift;
	
	my $dconf = $o->config;
	
	if ($o->{one_instance})
	{
		sleep 1;
		return if $o->ping;
	}
	
	if ($dconf->{errorlog})
	{
		# фильтруем базар
		close STDERR;
		close STDOUT;
		close STDIN;
		open STDERR, '>>:utf8', $dconf->{errorlog} or warnings::warnif "Can`t open(>>:utf8) error log '$dconf->{errorlog}': $!";
		
		#open STDOUT, '>&', STDERR;
	}
	
	warnings::warnif "Starting a daemon: $dconf->{socket}...";
	
	defined (my $dpid = fork) or die "Cannot fork for daemon: $!";
	if ($dpid)
	{
		warnings::warnif "Forked for daemon: $dpid";
		return $dpid;
	}
	
	warnings::warnif "pidfile '$dconf->{pidfile}' was owerwriten by $$" if -e $dconf->{pidfile};
	var2f $$, $dconf->{pidfile};
	
	# выходим из группы процессов (PPID = 1)
	setsid or die "Cannot setsid() for daemon";
	
	# переназываем процесс
	$0 = $dconf->{procname} if $dconf->{procname};
	
	{
		# создаем слушающий сокет
		my $listen = start_server_ex($dconf->{socket});
		
		$o->daemon_fix_signals;
		
		$o->daemon_load;
		$o->daemon_listen($listen);
		$o->daemon_unload;
		
		close $listen;
		
		unlink $o->socket_address if $o->socket_type eq 'local';
	}
	
	if ($o->{quit_type} eq 'soft')
	{
		sleep while $o->{kids} && %{$o->{kids}};
	}
	
	unlink $dconf->{pidfile};
	
	exit;
}


sub daemon_fix_signals
{
	my $o = shift;
	
	# учитывем потомков
	$o->{reaper} = sub
	{
		while ((my $kid = waitpid -1, WNOHANG) > 0)
		{
			delete $o->{kids}->{$kid};
			warnings::warnif "Reaped: $kid";
		}
		$SIG{CHLD} = $o->{reaper};
	};
	
	$SIG{CHLD} = $o->{reaper};
	
	# другие сигналы
	$SIG{TERM}	= sub { $o->daemon_hard_quit };
	$SIG{INT}	= sub { $o->daemon_soft_quit };
	$SIG{HUP}	= sub { $o->daemon_restart };
	$SIG{USR1}	= sub { $o->daemon_usr1 };
	$SIG{USR2}	= sub { $o->daemon_usr2 };
}

sub daemon_clear_signals
{
	my $o = shift;
	
	$SIG{CHLD} = $SIG{TERM} = $SIG{INT} = $SIG{HUP} = $SIG{USR1} = $SIG{USR2} = undef;
}


sub daemon_soft_quit
{
	my $o = shift;
	
	warnings::warnif "daemon_soft_quit: \$o->{kids} = $o->{kids}";
	$o->{daemon_loop} = 0;
	$o->{quit_type} = 'soft';
}


sub daemon_hard_quit
{
	my $o = shift;
	
	warnings::warnif "daemon_hard_quit: \$o->{kids} = '$o->{kids}'";
	
	if ($o->{kids})
	{
		for my $kid ( keys %{ $o->{kids} } )
		{
			unless ($kid)
			{
				warnings::warnif 'Undefined kid found in $o->{kids} keys.';
				delete $o->{kids}->{$kid};
			}
			
			kill 'TERM' => $kid
		}
	}
	
	$o->{daemon_loop} = 0;
	$o->{quit_type} = 'hard';
}


sub daemon_restart
{
	$_[0]->{daemon_restart} = 0;
}


sub daemon_listen
{
	my $o = shift;
	my $serv = shift;
	
	while ($o->{daemon_loop})
	{
		if (accept my $clnt, $serv)
		{
			#warn 'dl: ' . $o->{daemon_loop};
			autoflush $clnt;
			#my $kid = 0;
			defined ( my $kid = fork ) or die "Can`t fork for client: $!.";
			
			if ($kid)
			{
				# запоминаем пид
				$o->{kids}->{$kid} = {time => time};
				warnings::warnif "Forked for client: $kid";
			}
			else
			{
				$o->daemon_clear_signals;
				# спички — детям не игрушка!
				close $serv;
				
				my $res = eval { $o->daemon_accept($clnt) };
				die "Can`t daemon_accept:\n$@" if $@;
				exit $res;
			}
			
			close $clnt;
		}
	}
}


sub daemon_accept {VIRTUAL}
sub daemon_process {VIRTUAL}
sub daemon_load {VIRTUAL}
sub daemon_unload {VIRTUAL}
sub daemon_usr1 {VIRTUAL}
sub daemon_usr2 {VIRTUAL}




sub restart { return shift->sig('HUP') }


sub soft_quit { return shift->sig('INT') }
sub hard_quit { return shift->sig('TERM') }


sub kill { return shift->sig('KILL') }


sub ping { return shift->sig(0) or $!{EPERM} }


sub sig
{
	my $o = shift;
	my $sig = shift;
	
	return unless my $pid = $o->pid;
	
	undef $!;
	return CORE::kill $sig => $pid;
}


sub pid
{
	my $o = shift;
	my $sig = shift;
	
	return f2var($o->config->{pidfile}) || undef;
}


sub socket
{
	my $o = shift;
	return undef unless $o->ping;
	
	my $s = get_connection_ex($o->config->{socket}) or return undef;
	autoflush $s;
	return $s;
}


sub socket_type
{
	my ($type, undef) = split /:/, $_[0]->config->{socket}, 2;
	return $type;
}


sub socket_address
{
	my (undef, $addr) = split /:/, $_[0]->config->{socket}, 2;
	return $addr;
}


#–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––


sub start_server_ex
{
	my ($type, $addr) = split /:/, $_[0], 2;
	
	if ($type eq 'tcp')
	{
		my ($host, $port) = split /:/, $addr, 2;
		return start_server_tcp($host, $port);
	}
	elsif ($type eq 'local')
	{
		return start_server_local($addr);
	}
	else
	{
		Carp::croak "Unknown socket type '$type'";
	}
}


sub start_server_tcp
{
	my $host = shift;
	my $port = shift;
	
	die "Bad tcp addres $host:$port" unless $host && $port;
	
	my $iaddr = inet_aton($host);
	my $my_addr = sockaddr_in($port, $iaddr);
	
	my $server;
	CORE::socket $server, PF_INET, SOCK_STREAM, getprotobyname 'tcp';
	#setsockopt($server,SOL_SOCKET,SO_REUSEADDR, 1);
	
	bind $server, $my_addr or					die "Could not bind to $host:$port";
	listen $server, SOMAXCONN or				die "Could not listen on $host:$port";
	
	return $server;
}


sub start_server_local
{
	my $addr = shift;
	die "Empty local addres." unless $addr;
	
	unlink $addr;
	
	CORE::socket my $server, PF_UNIX, SOCK_STREAM, 0;
	bind $server, sockaddr_un($addr) or			die "Could not bind to $addr, because: $!";
	listen $server, SOMAXCONN or				die "Could not listen on $addr, because: $!";
	
	return $server;
}


sub get_connection_ex
{
	my ($type, $addr) = split /:/, $_[0], 2;
	
	if ($type eq 'tcp')
	{
		my ($host, $port) = split /:/, $addr;
		return get_connection_tcp($host, $port);
	}
	elsif ($type eq 'local')
	{
		return get_connection_local($addr);
	}
}


sub get_connection_tcp
{
	my ($host, $port) = @_;
	
	unless($host && $port){ die "Bad tcp addres: '$host:$port'"; }
	
	my $iaddr = inet_aton($host);
	my $paddr = sockaddr_in($port, $iaddr);
	
	my $server;
	CORE::socket($server,PF_INET,SOCK_STREAM, getprotobyname('tcp'));
	
	return connect($server, $paddr) ? $server : undef;
}


sub get_connection_local
{
	my $addr = shift;
	
	die "Empty local addres." unless $addr;
	
	my $server;
	CORE::socket($server, PF_UNIX, SOCK_STREAM, 0);
	
	return connect($server,sockaddr_un($addr))?$server:undef;
}



1;