package EML::login;

my $w;

sub root
{
	if($main::gid != 0){ main::err403('gid != 0'); }
	if($main::uid < 1){ main::err403('uid < 1'); }


}

sub act
{
	my ($act,$login,$pas) = @_;

	EML::unflush();

	if($act eq 'in'){

		$main::jlogin->login($login,$pas);


		if($main::jlogin->{'error'}){

			print "Content-type: text/html\n\n";
			print '<center><font color=red>Ошибка:</font> ',$main::jlogin->{'error'},'';

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
END

}


return 1;