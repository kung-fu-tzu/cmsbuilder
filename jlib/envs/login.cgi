package EML::login;
use strict qw(subs vars);
my $w;

sub root
{
	if($main::gid != 0){ main::err403('gid != 0'); }
	if($main::uid < 1){ main::err403('uid < 1'); }


}

sub act
{
	my ($act,$login,$pas) = @_;

	main::unflush();

	my $jl = main::JLogin::new($main::dbh);

	if($act eq 'in'){

		$jl->login($login,$pas);


		if($jl->{'error'}){

			print "Content-type: text/html\n\n";
			print '<center><font color=red>Ошибка:</font> ',$jl->{'error'},'';

		}else{
			print "Location: /\n\n";
		}

		exit();

	}

	print "Content-type: text/html\n\n";

}

sub form
{

print <<END;
<FORM action="?" method=POST>
<center>
<INPUT type="hidden" value="in" name=action>
<INPUT type="text" value="root" name=login>
<br><br>
<INPUT type="password" value="root" name=pas>
<br><br>
<INPUT type="submit" value="Войти...">
</center>
</FORM>
<br><a href=?action=in&pas=leonov&login=JPEG>JPEG</a>
END

}


return 1;