

sub err404
{
	unflush();
	
	my $verr = "<br><h4><font color=red>$_[0]</font></h4><br>";
	if(!$print_error){$verr = ''}
	
	print "Location: /errors/404.html\n\n";
	
	print STDERR 'EML.CGI 404 ERROR: '.$_[0];
	exit();
}

sub err403
{
	unflush();
	
	my $verr = "<br><h4><font color=red>$_[0]</font></h4><br><a href='/login.ehtml'>Login...</a>";
	if(!$print_error){$verr = ''}
	
	print "Location: /errors/403.html\n\n";
	
	print STDERR 'EML.CGI 403 ERROR: '.$_[0];
	exit();
}

sub err505
{
	unflush();
	
	my $verr = "<br><h4><font color=red>$_[0]</font></h4><br>";
	if(!$print_error){$verr = ''}
	
	print "Location: /errors/505.html\n\n";
	
	print STDERR 'EML.CGI 505 ERROR: '.$_[0].'; '.$@;
	exit();
}

1;