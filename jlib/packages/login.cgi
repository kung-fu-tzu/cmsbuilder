package login;
use strict qw(subs vars);

sub cms
{
	if(!$eml::do_users){ return; }
	
	if($eml::gid < 1){ eml::err403('gid < 1'); }
	if($eml::uid < 1){ eml::err403('uid < 1'); }
	
	if($eml::g_group->{'cms'} != 1){ eml::err403('$g_group->{"cms"} != 1'); }
}

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