# (с) Леонов П.А., 2005

package register;
use strict qw(subs vars);

# !!! Этот код может не соответствовать стандарту 2.0
#	 Пакет будет выполнен в виде модуля.

=comm

sub register
{
	my($login,$pas,$email,$icq,$city,$nick,$pas2,$action) = @_;
	
	if($action eq 'reg'){
		
		my @err;
		
		if($login =~ m/(\W)/){ push @err, 'Логин содержит недопустимый символ "'.$1.'"';}
		if($pas =~ m/([^\wа-яА-Я])/){ push @err, 'Пароль содержит недопустимый символ "'.$1.'"';}
		if($city =~ m/([^\wа-яА-Я])/){ push @err, 'Город содержит недопустимый символ "'.$1.'"';}
		if($nick =~ m/([^\wа-яА-Я])/){ push @err, 'Ник содержит недопустимый символ "'.$1.'"';}
		if($icq =~ m/(\D)/){ push @err, 'ICQ содержит не цифру"'.$1.'"';}
		
		if(length($login) < 1){ push @err, 'Логин пуст';}
		if(length($pas) < 1){ push @err, 'Пароль пуст';}
		if($pas ne $pas2){ push @err, 'Пароли не совпадают';}
		
		if($email =~ m/([^\w\.\@])/){ push @err, 'E-Mail содержит недопустимый символ "'.$1.'"';}
		if($email !~ m/\w+\@\w+\.\w+/){ push @err, 'Формат E-Mail неверен';}
		
		if($eml::uid > 0){ push @err, 'Вы уже вошли под именем <b>'.$eml::g_user->{'name'}.'</b>';}
		
		my $tu = MyUser::new();
		
		if($#err == -1){
			
			$tu->sel(' login = ? ',$login);
			if($tu->{ID} > 0){ push @err, 'Пользователь с таким логином уже существует';}
			
			$tu->sel(' email = ? ',$email);
			if($tu->{ID} > 0){ push @err, 'Пользователь с таким E-Mail уже существует';}
			
			$tu->sel(' name = ? ',$nick);
			if($tu->{ID} > 0){ push @err, 'Пользователь с таким ником уже существует';}			
		}
		
		if($#err > -1){
			print '<br><font color=red>Ошибка:</font> ';
			print join('<br><font color=red>Ошибка:</font> ',@err);
		}
		
		if($#err == -1){
			
			$tu->load('cre');
			
			$tu->{'login'} = $login;
			$tu->{'pas'} = $pas;
			$tu->{'city'} = $city;
			$tu->{'name'} = $nick;
			$tu->{'icq'} = $icq;
			$tu->{'email'} = $email;
			$tu->{'gid'} = 1;
			
			$tu->save();
			$tu->clear();
			
			eml::unflush();
			
			JLogin::login($login,$pas);
			
			print "Location: /\n\n";
			
		}
		
	}
	
	print "

<FORM action=\"/register.ehtml\" method=post>
<input type=hidden name=action value=reg>
<TABLE WIDTH=295
 BORDER=0 CELLSPACING=0 CELLPADDING=0 style=\"WIDTH: 250px; HEIGHT: 119px\">
	<TR>
		<TD>Ник:</TD>
		<TD width=5><INPUT class=input value='$nick' name=nick></TD>
	</TR>
	<TR>
		<TD>Логин:</TD>
		<TD><INPUT class=input value='$login' name=login></TD>
	</TR>
	<TR>
		<TD>Пароль:</TD>
		<TD><INPUT type=password class=input name=pas></TD>
	</TR>
	<TR>
		<TD>Подтвердить:</TD>
		<TD><INPUT type=password class=input name=pas2></TD>
	</TR>
	<TR>
		<TD>E-Mail</TD>
		<TD><INPUT class=input value='$email' name=email></TD>
	</TR>
	<TR>
		<TD>Город</TD>
		<TD><INPUT class=input value='$city' name=city></TD>
	</TR>
	<TR>
		<TD>Номер ICQ</TD>
		<TD><INPUT class=input value='$icq' name=icq></TD>
	</TR>
</TABLE>
<br><br>
<input type=submit class=input value=\"Зарегистрироваться...\">

</FORM>

";
	
	
}



sub me
{
	my $rid = shift;

	if($eml::uid > 0){

	print 'Вы: <b>',$eml::g_user->{'name'},'</b> <a href="/login.ehtml?action=out">Выйти</a>';

	if($eml::gid == 0){ print '<br><a href="/admin/?class=Razdel">Админка</a>'; }

	}else{

print <<ENDD;

<form name="authorise" method="post" action="/login.ehtml">
<input name="action" type="hidden" value="in">
<br>
<table width="100%" border="0">
<tr> 
<td><p>Ln: 
<input name="login" type="text" size="10" class="input">
<br>
Ps: 
<input name="pas" type="password" size="10" class="input">
<br>
</p>
</td>
</tr>
<tr>
<td align="right"><input type="submit" name="Submit" value=".enter">
</td>
</tr>
</table>
</form>

<table width="100%" border="0">
<tr><td><a href="/register.ehtml">Зарегистрироваться&gt;</a></td></tr>
</table>

ENDD
	
	}
	
}

=cut

1;