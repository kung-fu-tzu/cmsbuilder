# (�) ������ �.�., 2005

package CMSBuilder::Starter;
use strict qw(subs vars);

our $already_loaded;

sub start
{
	my $starts = $CMSBuilder::Config::server_type || 'cgi';
	
	if($starts eq 'cgi')
	{
		start_cgi();
	}
	elsif($starts eq 'cgi-server')
	{
		start_cgi_server();
	}
	elsif($starts eq 'http-server')
	{
		
	}
	elsif($starts eq 'rpc-server')
	{
		
	}
}

sub start_cgi_server
{
	if($ARGV[0] eq 'server')
	{
		require CMSBuilder::Starter::cgi_server_server;
		CMSBuilder::Starter::cgi_server_server::start();
	}
	else
	{
		require CMSBuilder::Starter::cgi_server_cgi;
		CMSBuilder::Starter::cgi_server_cgi::start();
	}
}

sub start_cgi
{
	require CMSBuilder;
	
	################################################################################
	
	unless($already_loaded)
	{
		# �������� � ����������
		CMSBuilder->load();
	}
	
	
	# ������������� � ������ ������
	CMSBuilder->init();
	
	# ���������� ������
	CMSBuilder::EML->init();
	CMSBuilder::EML->doall();
	
	# ����� ������: �����, ����, ���� � �.�.
	CMSBuilder->destruct();
	
	
	unless($already_loaded)
	{
		# ��������
		CMSBuilder->unload();
	}
	
	################################################################################
	
	$already_loaded = 1;
}

1;