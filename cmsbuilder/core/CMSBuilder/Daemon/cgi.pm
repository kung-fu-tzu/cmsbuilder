# (с) Леонов П.А., 2005

package CMSBuilder::Daemon::cgi;
use strict;
use utf8;

use base 'CMSBuilder::Daemon';

use CMSBuilder::SysUtils qw(VIRTUAL);


sub client_proxy { $_[0]->client_send($_[0]->client_socket) }

sub client_send
{
	my $o = shift;
	my $server = shift;
	
	die '$server is undefined' unless $server;
	
	
	#$ENV{'CMSB_PASS_HASH'} = Digest::MD5::md5_hex($CMSBuilder::Config::mysql_pas);
	
	my $env = '';
	
	for my $key (keys %ENV)
	{
		$env .= $key . '=' . unpack('H*', $ENV{$key}) . "\n";
	}
	
	print $server $env . "\n";
	
	my $rcont;
	#my $in = select;
	binmode STDIN;
	read STDIN, $rcont, $ENV{CONTENT_LENGTH};
	
	
	binmode $server;
	print $server $rcont;
	
	while (my $res = <$server>) { print $res }
	
	close $server;
	
	#print "Content-type: text/html\n\nOK",$rcont,$ENV{'CONTENT_LENGTH'}; return 1;
	
	return 1;
}


sub client_socket
{
	my $o = shift;
	
	my $s = $o->socket;
	
	unless ($s)
	{
		warn "Manualy starting server $o, because of socket: $!";
		$o->start;
		
		for (1 .. 5)
		{
			sleep 1;
			last if $s = $o->socket;
		}
	}
	
	die "Server down. Couldn`t connect to $o, because of: $!" unless $s;
	
	return $s;
}


#–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

sub daemon_process {VIRTUAL}

sub daemon_accept
{
	my $o = shift;
	my $clnt = shift;
	
	%ENV = ();
	
	eval
	{
		#local $SIG{ALRM} = sub {die 'To much time for reading envs'};
		#alarm 5;
		
		# прочитаем окружение от клиента
		while (my $env = <$clnt>)
		{
			chomp $env;
			last unless $env;
			
			my ($key, $val) = split /=/, $env;
			$val = pack 'H*', $val;
			
			$ENV{$key} = $val
		}
		
		#alarm 0;
	};
	#alarm 0;
	
	die $@ if $@;
	
	# прочитаем тело от клиента
	binmode $clnt;
	read $clnt, my $rcont, $ENV{CONTENT_LENGTH};
	
	# перенаправим ввод на чтение из буфера
	open STDIN, '<', \$rcont;
	binmode STDIN;
	
	# перенаправим вывод в сокет
	open STDOUT, '>&', $clnt;
	binmode STDOUT, ':utf8';
	select STDOUT;
	
	#my $cgi = CGI::Minimal->new;
	
	#print "Content-type: text/html\n\nreading ",*STDIN,<STDIN>;
	
	$o->daemon_process();
	
	close STDIN;
	close $clnt;
}



1;