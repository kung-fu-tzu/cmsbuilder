

sub err404
{
	unflush();

	my $verr = "<br><h4><font color=red>$_[0]</font></h4><br>";
	if(!$print_error){$verr = ''}

	print <<"	END";
	Status: 404 Not Found
	Pragma: no-cache
	Expires: 0

<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>404 Not Found</TITLE>
</HEAD><BODY>
<H1>Not Found</H1>
The requested URL $ENV{REQUEST_URI} was not found on this server.<P>
<HR>
$ENV{SERVER_SIGNATURE}$verr
</BODY></HTML>
	END

	die('EML.CGI 404 ERROR: '.$_[0]);

}

sub err403
{
	unflush();

	my $verr = "<br><h4><font color=red>$_[0]</font></h4><br><a href='/login.ehtml'>Login...</a>";
	if(!$print_error){$verr = ''}

	print <<"	END";
	Status: 403 Access Denined
	Pragma: no-cache
	Expires: 0

<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>404 Access Denined</TITLE>
</HEAD><BODY>
<H1>Access Denined</H1>
The requested URL $ENV{REQUEST_URI} require authorisation! Login please.<P>
<HR>
$ENV{SERVER_SIGNATURE}$verr
</BODY></HTML>
	END

	die('EML.CGI 403 ERROR: '.$_[0]);

}

sub err505
{

	unflush();

	my $verr = "<br><h4><font color=red>$_[0]</font></h4><br>";
	if(!$print_error){$verr = ''}

	print <<"	END";
	Status: 505 Error
	Pragma: no-cache
	Expires: 0

<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>500 Internal Server Error</TITLE>
</HEAD><BODY>
<H1>Internal Server Error</H1>
The server encountered an internal error or
misconfiguration and was unable to complete
your request.<P>
Please contact the server administrator,
 pete\@nm.ru and inform them of the time the error occurred,
and anything you might have done that may have
caused the error.<P>
More information about this error may be available
in the server error log.<P>
<HR>
$ENV{SERVER_SIGNATURE}$verr
</BODY></HTML>
	END

	die('EML.CGI 505 ERROR: '.$_[0].'; '.$@);

}

1;