package login;
use strict qw(subs vars);

sub act
{
	my ($act,$login,$pas);
	
	$act = eml::param('action');
	$login = eml::param('login');
	$pas = eml::param('pas');
	
	srand();
	
	if($act eq 'in'){
		
		if(!JLogin::login($login,$pas)){
			
			print '<center><font color=red>Ошибка:</font> ',$JLogin::errstr,'';
			
		}else{
			print '<script>location.href = "/?'.rand().'"</script>';
			#print '<b>',$eml::sess{'JLogin_sid'},'</b>';
		}
	}
	
	if($act eq 'out'){
		
		
		if(!JLogin::logout()){
			
			print '<center><font color=red>Ошибка:</font> ',$JLogin::errstr,'';
			
		}else{
			print '<script>location.href = "/?'.rand().'"</script>';
		}
		
		
	}
	
}

sub form
{

print <<"	END";
	<FORM action="?" method=POST>
	<center>
	<INPUT type="hidden" value="in" name="action">
	<INPUT type="text" value="" name=login>
	<br><br>
	<INPUT type="password" value="" name=pas>
	<br><br>
	<INPUT type="submit" value="Войти...">
	</center>
	</FORM>
	<br><br><center>
	END
	
	eml::su_start();
	
	my $tu = User::new();
	my $u;
	for $u ($tu->sel_where(' 1 ')){
		
		print '<a href="?action=in&pas=',$u->{'pas'},'&login=',$u->{'login'},'">',$u->name(),'</a><br>';
	}
	
	print '</center>';
	
	eml::su_stop();
	
}


return 1;