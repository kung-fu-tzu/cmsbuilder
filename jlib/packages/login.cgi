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

print <<END;
<FORM action="?" method=POST>
<center>
<INPUT type="hidden" value="in" name=action>
<INPUT type="text" value="" name=login>
<br><br>
<INPUT type="password" value="" name=pas>
<br><br>
<INPUT type="submit" value="Войти...">
</center>
</FORM>
<br>
END

}


return 1;