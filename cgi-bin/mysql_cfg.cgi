#!/usr/bin/perl

{

	my $m_db = 'DBI:mysql:engine';
	my $m_pas = 'root';
	my $m_login = 'pas';


sub ret_mysql
{

	my @ar = ($m_db,$m_pas,$m_login);

	#($m_db,$m_pas,$m_login) = (0,0,0);

	return @ar;
}

}


1;