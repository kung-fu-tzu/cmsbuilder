package JLogin;
use strict qw(subs vars);

use vars '$errstr';
$errstr = '';

sub login
{
	my($cook,$l,$p,$rnd,$group);
	$l = shift;
	$p = shift;
	
	if($l eq '' or $p eq ''){ return err('Пустое имя пользователя или пароль.'); }
	
	my $tu = User::new();
	
	eml::su_start();
	$tu->sel_one(' login = ? ',$l);
	eml::su_stop();
	
	if($tu->{'ID'} < 1){return err("Неверное имя пользователя.");}
	if($tu->{'pas'} ne $p){return err("Неверный пароль.");}
	
	eml::su_start();
	$group = $tu->papa();
	eml::su_stop();
	if($group eq undef){return err("Вы не состоите ни в одной группе.");}
	$group->clear();
	
	# login and password OK
	
	srand();
	$rnd = rand() . rand();
	$rnd =~ s/\D//g;
	$rnd = substr($rnd,0,20);
	
	$tu->{'sid'} = $rnd;
	
	eml::su_start();
	$tu->save();
	$tu->clear();
	eml::su_stop();
	
	$eml::sess{'JLogin_sid'} = $rnd;
	
	return 1;
}

sub logout
{
	my(%cook,$cook,$l,$p,$sid);
	
	$sid = $eml::sess{'JLogin_sid'};
	
	if($sid eq '' or $sid == 0){ return( err("Вы не вошли в систему.") ); }
	
	my $tu = User::new();
	$tu->sel_one(' sid = ? ',"$sid");
	
	if($tu->{'ID'} < 1){ return( err("Ваш ключ устарел. Войдите в систему повторно.") ); }
	
	$tu->{'sid'} = 0;
	
	delete( $eml::sess{'JLogin_sid'} );
	
	return 1;
}

sub verif
{
	my($co,%cook,$sid,$group);
	
	eml::su_start();
	
	my $gu = User::new();
	my $gg = UserGroup::new();
	$gu->load(2); $gg->load(2);
	$gg->{'_guest'} = 1;
	
	$sid = $eml::sess{'JLogin_sid'};
	
	if($sid eq '' or $sid == 0){ return ($gu,$gg); }
	
	my $tu = User::new();
	
	$tu->sel_one(' sid = ? ',"$sid");
	$tu = $tu->no_cache();
	
	#print STDERR $tu->{'ID'};
	
	if($tu->{'ID'} < 1){ return ($gu,$gg); }
	
	$group = $tu->papa();
	$group = $group->no_cache();
	
	if($group eq undef){ return ($gu,$gg); }
	
	
	return ($tu,$group);
}

sub err
{
	$errstr = shift;
	return (undef,undef);
}

return 1;

