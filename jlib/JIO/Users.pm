# (с) Леонов П.А., 2005

package JIO::Users;
use strict qw(subs vars);

our $errstr;
our @users_s;
our @groups_s;
our @udo_s;

sub init
{
	$errstr = '';
	@users_s = ();
	@groups_s = ();
	@udo_s = ();
}

sub clear
{
	$errstr = '';
	@users_s = ();
	@groups_s = ();
	@udo_s = ();
}

sub access_off
{
	push @udo_s, $JConfig::access_on_e;
	$JConfig::access_on_e = 0;
}

sub access_on
{
	push @udo_s, $JConfig::access_on_e;
	$JConfig::access_on_e = 1;
}

sub access_ret
{
	unless(@udo_s){ return; }
	$JConfig::access_on_e = pop @udo_s;
}

sub acs_off(&)
{
	my $code = shift;
	access_off();
	my $ret = &$code;
	access_ret();
	return $ret;
}

sub acs_on(&)
{
	my $code = shift;
	access_on();
	my $ret = &$code;
	access_ret();
	return $ret;
}

sub su_start
{
	my $uid = shift || $JConfig::su_admin;
	my $u_do;
	unless($uid){ return 0; }
	
	JDBI::cache_clear();
	
	if($JDBI::user and $JDBI::group)
	{
		push @users_s,  $JDBI::user;
		push @groups_s, $JDBI::group;
	}
	
	access_off();
	my $tu = User->new($uid);
	my $tg = $tu->papa();
	access_ret();
	
	$JDBI::user  = $tu;
	$JDBI::group = $tg;
	
	return 1;
}

sub su_stop
{
	unless(@groups_s and @users_s){ return 0; }
	
	$JDBI::user  = pop @users_s;
	$JDBI::group = pop @groups_s;
}

sub login
{
	my($class,$l,$p,$rnd,$tg,$tu);
	$class = shift;
	$l = shift;
	$p = shift;
	
	if($l eq '' or $p eq ''){ return err('Пустое имя пользователя или пароль.'); }
	
	acs_off { $tu = User->sel_one(' login = ? ',$l); };
	
	unless($tu->{'ID'}){ return err("Неверное имя пользователя."); }
	
	unless($JConfig::users_pasoff)
	{
		$p = JDBI::MD5($p);
		if($tu->{'pas'} ne $p){ return err("Неверный пароль."); }
	}
	
	acs_off { $tg = $tu->papa(); };
	unless($tg){ return err("Вы не состоите ни в одной группе."); }
	
	# login and password OK
	
	srand();
	$rnd = JDBI::MD5(rand() . rand());
	
	$tu->{'sid'} = $rnd;
	
	acs_off { $tu->save(); };
	
	JIO::sess()->{'JIO::Users.sid'} = $rnd;
	
	return 1;
}

sub logout
{
	my($sid,$tu);

	$sid = JIO::sess()->{'JIO::Users.sid'};
	
	if(length($sid) < 30){ return( err("Вы не вошли в систему.") ); }
	
	$tu = User->sel_one(' sid = ? ',"$sid");
	
	unless($tu->{'ID'}){ return( err("Ваш ключ устарел. Войдите в систему повторно.") ); }
	
	$tu->{'sid'} = 0;
	
	acs_off { $tu->save(); };
	
	delete( JIO::sess()->{'JIO::Users.sid'} );
	
	return 1;
}

sub verif
{
	my($sid,$tu,$tg);
	
	$sid = JIO::sess()->{'JIO::Users.sid'};
	
	if(length($sid) < 30){ return 0; }
	
	acs_off { $tu = User->sel_one(' sid = ? ',"$sid"); };
	
	unless($tu->{'ID'}){ return 0; }
	
	acs_off { $tg = $tu->papa(); };
	
	unless($tg){ return 0; }
	
	su_start($tu->{'ID'});
	
	return 1;
}

sub err
{
	$errstr = shift;
	return 0;
}

return 1;

