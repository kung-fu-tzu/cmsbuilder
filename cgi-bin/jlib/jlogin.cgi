package JLogin;
use strict qw(subs vars);

my $table = 'dbo_myuser';

sub new
{
	my $self = {};
	bless($self);

	$self->{"error"} = "";

	$self->{"dbh"} = shift;

	return $self;
}

sub login
{
	my($cook,%user,$l,$p,$str,@row,$rnd);
	my $self = shift;
	$l = shift;
	$p = shift;

	if($l eq '' or $p eq ''){ return $self->err('Пустое имя пользователя.'); }

	$str = $self->{"dbh"}->prepare( "SELECT login, pas FROM $table WHERE login = ?" );
	$str->execute("$l");

	@row = $str->fetchrow_array();

	if($#row < 0){return $self->err("Неверное имя пользователя.");}
	if($row[0] ne $l or $row[1] ne $p){return $self->err("Неверный пароль.");}

	# login and password OK

	srand();
	$rnd = rand() . rand();
	$rnd =~ s/\D//g;
	$rnd = substr($rnd,0,20);


	$str = $self->{"dbh"}->prepare( "UPDATE $table SET sid = ? where login = ?" );
	$str->execute($rnd,$l);

	$user{"sid"} = $rnd;
	$user{"test"} = 'one';

	my $co = new CGI;

	$cook = $co->cookie(
		-name=>"JLogin",
		-value=>\%user,
		-path=>'/',
		-expires=>'+365d'

	);

	print 'Set-Cookie: ',$cook->as_string,"\n";
	#print $co->header(-cookie=>$cook);

	return 1;
}

sub logout
{
	my(%cook,$cook,%user,$l,$p,$str,@row,$sid);
	my $self = shift;


	my $co = new CGI;
	%cook = $co->cookie( "JLogin" );

	$sid = $cook{"sid"};
	$sid =~ s/\D//;

	if($sid eq "" or $sid == 0){ return( $self->err("Вы не вошли в систему.") ); }

	$str = $self->{"dbh"}->prepare( "SELECT ID FROM $table WHERE sid = ?" );
	$str->execute("$sid");

	@row = $str->fetchrow_array();

	if($#row < 0){ return( $self->err("Ваш ключ устарел. Войдите в систему повторно.") ); }


	$str = $self->{"dbh"}->prepare( "UPDATE $table SET sid = 0 where sid = ?" );
	$str->execute($sid);


	$user{"sid"} = 0;


	$cook = $co->cookie(
		-name=>"JLogin",
		-value=>\%user,
		-path=>'/',
		-expires=>'+365d'

	);



	#print $co->header(-cookie=>$cook);
        print 'Set-Cookie: ',$cook->as_string,"\n";

	return 1;
}

sub verif
{
	my($self,$co,%cook,$sid,@row,$str);
	$self = shift;

	$co = new CGI;
	%cook = $co->cookie( "JLogin" );

	$sid = $cook{"sid"};
	$sid =~ s/\D//;

	if($sid eq "" or $sid == 0){return (-1,-1); }

	$str = $self->{"dbh"}->prepare( "SELECT ID, GID FROM $table WHERE sid = ?" );
	$str->execute($sid);

	@row = $str->fetchrow_array();

	if($#row < 0){ return (-1,-1); }

	@row;

}

sub cre
{
	my($table,$str);
	my $self = shift;

	$table =<<'	END';
	dbo_user (
		ID INT NOT NULL AUTO_INCREMENT,
		login VARCHAR(20) NOT NULL,
		pas VARCHAR(20) NOT NULL,
		sid VARCHAR(20) NOT NULL,
		PRIMARY KEY (ID),
		UNIQUE KEY sid (sid),
		INDEX(sid),
		INDEX(login)
	)
	END

	$str = $self->{"dbh"}->prepare("create table $table;");
	$str->execute() or return( $self->err(DBI::errstr) );

	$str = $self->{"dbh"}->prepare( "INSERT INTO $table (ID,login,pas,sid) VALUES (?,?,?,?)" );
	$str->execute(1,"root","asdZ",0) or return( $self->err(DBI::errstr) );
	$str->execute(2,"root1","asdZ1",0) or return( $self->err(DBI::errstr) );


	return 1;
}

sub drop
{
	my($table,$str);
	my $self = shift;

	$str = $self->{"dbh"}->prepare("DROP TABLE $table;");
	$str->execute() or return( $self->err(DBI::errstr) );

	return 1;
}



sub err
{
	my $self = shift;
	my $errstr = shift;
	$self->{"error"} = $errstr;
	return 0;
}


return 1;







