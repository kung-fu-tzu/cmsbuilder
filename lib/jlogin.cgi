
package JLogin;

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

	$str = $self->{"dbh"}->prepare( "SELECT login, pas FROM jl_users WHERE login = ?" );
	$str->execute("$l");

	@row = $str->fetchrow_array();

	if($#row < 0){return $self->err("Bad login");}
	if($row[0] ne $l or $row[1] ne $p){return $self->err("Bad password");}

	# login and password OK

	srand();
	$rnd = rand() . rand();
	$rnd =~ s/\D//g;
	$rnd = substr($rnd,0,20);


	$str = $self->{"dbh"}->prepare( "UPDATE jl_users SET sid = ? where login = ?" );
	$str->execute($rnd,$l);

	$user{"sid"} = $rnd;
	$user{"test"} = 'one';

	$co = new CGI;

	$cook = $co->cookie(
		-name=>"JLogin",
		-value=>\%user,
		-path=>'/',
		-expires=>'+365d'

	);

	print $co->header(-cookie=>$cook);

	return 1;
}

sub logout
{
	my($cook,%user,$l,$p,$str,@row,$sid);
	my $self = shift;


	$co = new CGI;
	%cook = $co->cookie( "JLogin" );

	$sid = $cook{"sid"};
	$sid =~ s/\D//;

	if($sid eq "" or $sid == 0){ return( $self->err("You are not logged in!") ); }

	$str = $self->{"dbh"}->prepare( "SELECT uid FROM jl_users WHERE sid = ?" );
	$str->execute("$sid");

	@row = $str->fetchrow_array();

	if($#row < 0){ return( $self->err("Your sid is not valid!") ); }


	$str = $self->{"dbh"}->prepare( "UPDATE jl_users SET sid = 0 where sid = ?" );
	$str->execute($sid);


	$user{"sid"} = 0;

	#$co = new CGI;

	$cook = $co->cookie(
		-name=>"JLogin",
		-value=>\%user,
		-path=>'/',
		-expires=>'+365d'

	);



	print $co->header(-cookie=>$cook);

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

	if($sid eq "" or $sid == 0){return 0; }

	$str = $self->{"dbh"}->prepare( "SELECT uid FROM jl_users WHERE sid = ?" );
	$str->execute("$sid");

	@row = $str->fetchrow_array();

	if($#row < 0){ return 0; }

	return $row[0];

}

sub cre
{
	my($table,$str);
	my $self = shift;

	$table =<<'	END';
	jl_users (
		uid INT NOT NULL AUTO_INCREMENT,
		login VARCHAR(20) NOT NULL,
		pas VARCHAR(20) NOT NULL,
		sid VARCHAR(20) NOT NULL,
		PRIMARY KEY (uid),
		INDEX(sid),
		INDEX(login)
	)
	END

	$str = $self->{"dbh"}->prepare("create table $table;");
	$str->execute() or return( $self->err(DBI::errstr) );

	$str = $self->{"dbh"}->prepare( "INSERT INTO jl_users (uid,login,pas,sid) VALUES (?,?,?,?)" );
	$str->execute(1,"root","asdZ",0) or return( $self->err(DBI::errstr) );
	$str->execute(2,"root1","asdZ1",0) or return( $self->err(DBI::errstr) );


	return 1;
}

sub drop
{
	my($table,$str);
	my $self = shift;

	$str = $self->{"dbh"}->prepare("drop table jl_users;");
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







