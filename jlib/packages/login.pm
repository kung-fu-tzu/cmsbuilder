package login;
use strict qw(subs vars);
use CGI 'param';
use JDBI;

sub act
{
    my ($act,$login,$pas,$href);
    
    $href  = shift;
    $act   = param('act');
    $login = param('login');
    $pas   = param('pas');
    
    print $login;
    
    srand();
    
    unless($act){
	print 'Вы не вошли в систему или у Вас нет разрешений<br>для доступа к этому разделу или элементу.<br>';
    }
    
    if($act eq 'in'){
	
	if(!JIO::Users->login($login,$pas)){
	    
	    print '<font color="#FF0000">Ошибка:</font> ',$JIO::Users::errstr;
	    
	}else{
	    print '<script>location.href = "',$href,'?',rand(),'"</script>';
	}
    }
    
    if($act eq 'out'){
    	
    	if(!JIO::Users->logout()){
	    
	    print '<center><font color=red>Ошибка:</font> ',$JLogin::errstr,'';
	    
    	}else{
	    print '<script>location.href = "/?'.rand().'"</script>';
    	}
    	
    	
    }
    
}

sub list
{
    unless($JConfig::users_login_list){return;}
    
    my(@ga,@ua,$u,$g,$modu);
    
    JIO::Users::usr_off {
	
	print '<table><tr><td><p align="left">Система находится в тестовом режиме.<br> Выберите пользователя:</p>';
	
	$modu = url('ModUsers1');
	@ga = $modu->get_all();
	
	print $modu->name(),':<br><div class="left_dir"><div class="left_dir">';
	
	for $g (@ga){
		
		print '<b>',$g->name(),'</b><br><div class="left_dir">';
		
		for $u ($g->get_all()){
		    if($u->{'ID'} == $JConfig::user_guest){next;}
		    print '<a href="?act=in&login=',$u->{'login'},'&pas=*">',$u->name(),'</a><br>';
		}
		
		print '</div><br>';
	}
	
	print '</div></div></td></tr></table>';
	
    }
    
}


return 1;