package JLogin;
use strict qw(subs vars);

use vars '$errstr';
$errstr = '';

sub login
{
	my($cook,$l,$p,$rnd);
	$l = shift;
	$p = shift;
	
	if($l eq '' or $p eq ''){ return err('������ ��� ������������ ��� ������.'); }
	
	my $tu = User::new();
	
	$tu->sel_one(' login = ? ',$l);
	
	if($tu->{'ID'} < 0){return err("�������� ��� ������������.");}
	if($tu->{'pas'} ne $p){return err("�������� ������.");}
	if($tu->papa() eq undef){return err("�� �� �������� �� � ����� ������.");}
	
	# login and password OK
	
	srand();
	$rnd = rand() . rand();
	$rnd =~ s/\D//g;
	$rnd = substr($rnd,0,20);
	
	$tu->{'sid'} = $rnd;
	
	$eml::sess{'JLogin_sid'} = $rnd;
	
	return 1;
}

sub logout
{
	my(%cook,$cook,%user,$l,$p,$sid);
	
	my $co = new CGI;
	%cook = $co->cookie( "JLogin" );
	
	$sid = $cook{"sid"};
	$sid =~ s/\D//;
	
	if($sid eq '' or $sid == 0){ return( err("�� �� ����� � �������.") ); }
	
	my $tu = User::new();
	$tu->sel_one(' sid = ? ',"$sid");
	
	if($tu->{'ID'} < 0){ return( err("��� ���� �������. ������� � ������� ��������.") ); }
	
	$tu->{'sid'} = 0;
	
	$user{"sid"} = 0;
	
	
	delete( $eml::sess{'JLogin_sid'} );
	
	return 1;
}

sub verif
{
	my($co,%cook,$sid);
	
	$sid = $eml::sess{'JLogin_sid'};
	
	#print '<b> JLogin_sid = ',$eml::sess{'JLogin_sid'},'</b>';	
	
	if($sid eq '' or $sid == 0){ return (undef,undef); }
	
	
	my $tu = User::new();
	$tu->sel_one(' sid = ? ',"$sid");
	
	if($tu->{'ID'} < 0){ return (undef,undef); }
	if($tu->papa() eq undef){ return (undef,undef); }
	
	return ($tu,$tu->papa());
}

sub err
{
	$errstr = shift;
	return 0;
}

return 1;

