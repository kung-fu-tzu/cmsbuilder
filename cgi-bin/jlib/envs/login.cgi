package EML::login;
use strict qw(subs vars);
my $w;


sub register
{
	my($login,$pas,$email,$icq,$city,$nick,$pas2,$action) = @_;
	
	if($action eq 'reg'){
	
		my @err;
		
		if($login =~ m/(\W)/){ push @err, '����� �������� ������������ ������ "'.$1.'"';}
		if($pas =~ m/(\W)/){ push @err, '������ �������� ������������ ������ "'.$1.'"';}
		if($city =~ m/(\W)/){ push @err, '����� �������� ������������ ������ "'.$1.'"';}
		if($nick =~ m/(\W)/){ push @err, '��� �������� ������������ ������ "'.$1.'"';}
		if($icq =~ m/(\D)/){ push @err, 'ICQ �������� �� �����"'.$1.'"';}
		
		if(length($login) < 1){ push @err, '����� ����';}
		if(length($pas) < 1){ push @err, '������ ����';}
		if($pas ne $pas2){ push @err, '������ �� ���������';}
		
		if($email =~ m/([^\w\.\@])/){ push @err, 'E-Mail �������� ������������ ������ "'.$1.'"';}
		if($email !~ m/\w+\@\w+\.\w+/){ push @err, '������ E-Mail �������';}
		
		if($main::uid > 0){ push @err, '�� ��� ����� ��� ������ <b>'.$main::g_user->{'name'}.'</b>';}
		
		my $tu = MyUser::new();
		
		if($#err == -1){
		
			$tu->sel(' login = ? ',$login);
			if($tu->{ID} > 0){ push @err, '������������ � ����� ������� ��� ����������';}
			
			$tu->sel(' email = ? ',$email);
			if($tu->{ID} > 0){ push @err, '������������ � ����� E-Mail ��� ����������';}
			
			$tu->sel(' name = ? ',$nick);
			if($tu->{ID} > 0){ push @err, '������������ � ����� ����� ��� ����������';}			
		}
		
		if($#err > -1){
			print '<br><font color=red>������:</font> ';
			print join('<br><font color=red>������:</font> ',@err);
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
			
			main::unflush();
			
			my $jl = JLogin::new($main::dbh);
			$jl->login($login,$pas);
			
			print "Location: /\n\n";
			
		}
	
	}
	
	print "

<FORM action=\"/register.ehtml\" method=post>
<input type=hidden name=action value=reg>
<TABLE WIDTH=295
 BORDER=0 CELLSPACING=0 CELLPADDING=0 style=\"WIDTH: 250px; HEIGHT: 119px\">
	<TR>
		<TD>���:</TD>
		<TD width=5><INPUT class=input value='$nick' name=nick></TD>
	</TR>
	<TR>
		<TD>�����:</TD>
		<TD><INPUT class=input value='$login' name=login></TD>
	</TR>
	<TR>
		<TD>������:</TD>
		<TD><INPUT type=password class=input name=pas></TD>
	</TR>
	<TR>
		<TD>�����������:</TD>
		<TD><INPUT type=password class=input name=pas2></TD>
	</TR>
	<TR>
		<TD>E-Mail</TD>
		<TD><INPUT class=input value='$email' name=email></TD>
	</TR>
	<TR>
		<TD>�����</TD>
		<TD><INPUT class=input value='$city' name=city></TD>
	</TR>
	<TR>
		<TD>����� ICQ</TD>
		<TD><INPUT class=input value='$icq' name=icq></TD>
	</TR>
</TABLE>
<br><br>
<input type=submit class=input value=\"������������������...\">

</FORM>

";
	
	
}



sub root
{
	if($main::gid != 0){ main::err403('gid != 0'); }
	if($main::uid < 1){ main::err403('uid < 1'); }


}

sub me
{

	if($main::uid > 0){

	print '��: <b>',$main::g_user->{'name'},'</b> <a href="/login.ehtml?action=out">�����</a>';

	if($main::gid == 0){ print '<br><a href="/admin/">�������</a>'; }

	print '<br><br><table width="100%" border="0">

		<tr><td><a href="<#path>/newsforms">�������� �������&gt;</a><br></td></tr>

		</table>';


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
<tr><td><a href="/register.ehtml">������������������&gt;</a></td></tr>
</table>

ENDD

	}

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
			print '<center><font color=red>������:</font> ',$jl->{'error'},'';

		}else{
			print "Location: /\n\n";
		}

		exit();

	}

	if($act eq 'out'){

		$jl->logout();


		if($jl->{'error'}){

			print "Content-type: text/html\n\n";
			print '<center><font color=red>������:</font> ',$jl->{'error'},'';

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
<INPUT type="submit" value="�����...">
</center>
</FORM>
<br><a href=?action=in&pas=leonov&login=JPEG>JPEG</a>
END

}


return 1;