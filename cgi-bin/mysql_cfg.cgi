#!/usr/bin/perl

{

	my $m_db = 'DBI:mysql:engine';
	my $m_login = 'root';
	my $m_pas = 'pas';
	#my $m_db = 'DBI:mysql:webwork_engine';
	#my $m_login = 'webwork';
	#my $m_pas = 'sntglweZ';


sub ret_mysql
{

	my @ar = ($m_db,$m_login,$m_pas);

	#($m_db,$m_login,$m_pas) = (0,0,0);

	return @ar;
}

}


1;