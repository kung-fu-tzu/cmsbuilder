#!/usr/bin/perl

{

	my $m_db = 'DBI:mysql:webwork_engine';
	my $m_pas = 'webwork';
	my $m_login = 'sntglweZ';


sub ret_mysql
{

	my @ar = ($m_db,$m_pas,$m_login);

	#($m_db,$m_pas,$m_login) = (0,0,0);

	return @ar;
}

}


1;