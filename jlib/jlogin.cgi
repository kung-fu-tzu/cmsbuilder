package JLogin;
use strict qw(subs vars);

my $table;

sub new
{
	my $self = {};
	bless($self);
	
	$self->{"error"} = "";
	
	return $self;
}

sub login
{
	my($cook,%user,$l,$p,$rnd);
	my $self = shift;
	$l = shift;
	$p = shift;
	
	if($l eq '' or $p eq ''){ return $self->err('Пустое имя пользователя или пароль.'); }
	
	my $tu = User::new();
	
	$tu->sel_one(' login = ? ',$l);
	
	if($tu->{'ID'} < 0){return $self->err("Неверное имя пользователя.");}
	if($tu->{'pas'} ne $p){return $self->err("Неверный пароль.");}
	if($tu->papa() eq undef){return $self->err("Вы не состоите ни в одной группе.");}
	
	# login and password OK
	
	srand();
	$rnd = rand() . rand();
	$rnd =~ s/\D//g;
	$rnd = substr($rnd,0,20);
	
	$tu->{'sid'} = $rnd;
	
	$user{"sid"} = $rnd;
	
	my $co = new CGI;
	
	$cook = $co->cookie(
		-name=>"JLogin",
		-value=>\%user,
		-path=>'/',
		-expires=>'+365d'
	);
	
	print 'Set-Cookie: ',$cook->as_string,"\n";
	
	return 1;
}

sub logout
{
	my(%cook,$cook,%user,$l,$p,$sid);
	my $self = shift;


	my $co = new CGI;
	%cook = $co->cookie( "JLogin" );

	$sid = $cook{"sid"};
	$sid =~ s/\D//;

	if($sid eq '' or $sid == 0){ return( $self->err("Вы не вошли в систему.") ); }

	my $tu = User::new();
	$tu->sel_one(' sid = ? ',"$sid");

	if($tu->{'ID'} < 0){ return( $self->err("Ваш ключ устарел. Войдите в систему повторно.") ); }
	
	$tu->{'sid'} = 0;
	
	$user{"sid"} = 0;
	
	
	$cook = $co->cookie(
		-name=>"JLogin",
		-value=>\%user,
		-path=>'/',
		-expires=>'+365d'

	);
	
	
	print 'Set-Cookie: ',$cook->as_string,"\n";
	
	return 1;
}

sub verif
{
	my($self,$co,%cook,$sid);
	$self = shift;
	
	$co = new CGI;
	%cook = $co->cookie( "JLogin" );
	
	$sid = $cook{"sid"};
	$sid =~ s/\D//;
	
	if($sid eq "" or $sid == 0){ return (undef,undef); }
	
	my $tu = User::new();
	$tu->sel_one(' sid = ? ',"$sid");
	
	if($tu->{'ID'} < 0){ return (undef,undef); }
	if($tu->papa() eq undef){ return (undef,undef); }
	
	return ($tu,$tu->papa());
}

sub err
{
	my $self = shift;
	my $errstr = shift;
	$self->{"error"} = $errstr;
	return 0;
}

return 1;

