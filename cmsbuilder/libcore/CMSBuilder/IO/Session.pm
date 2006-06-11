# (с) Леонов П.А., 2005

package CMSBuilder::IO::Session;
use strict qw(subs vars);

use Exporter;
our @ISA = 'Exporter';
our @EXPORT = qw/$sess/;

use CMSBuilder::Utils;

our
(
	%sess,$sess,$sessid
);

our $sess = \%sess;

sub start
{
	%sess = ();
	
	my $dir = $CMSBuilder::Config::path_sess;
	
	mkdir($dir) unless -d $dir;
	
	my %cook = CGI::cookie("CMSBSession");
	
	$sessid = $cook{"id"};
	$sessid =~ s/\W//g;
	
	if( length($sessid) < 30 )
	{
		srand();
		
		do
		{
			$sessid = rand().rand();
			$sessid =~ s/\D//g;
			$sessid = uc(MD5(~$sessid));
		}
		while(-f $dir.'/'.$sessid);
		
	}
	
	dbmopen(%sess,$dir.'/'.$sessid,0600) or die('SESSION_NOT_OPEN ('.$dir.'/'.$sessid.'): '.$!."\n");
	
	$cook{'id'} = $sessid;
	
	my $dom = $ENV{'HTTP_HOST'};
	my @dom = split(/\./,$dom);
	
	if(@dom > 1)
	{
		$dom = '.'.$dom[$#dom-1].'.'.$dom[$#dom];
	}
	else
	{
		$dom = '';
	}
	
	my $send = CGI::cookie
	(
		-name=>"CMSBSession",
		-value=>\%cook,
		-path=>'/',
		-expires=>'+365d',
		-domain=>$dom
	);
	
	$CMSBuilder::IO::headers{'Set-Cookie'} = $send->as_string;
	
	return $send;
}

sub stop
{
	my @kl = keys %sess;
	dbmclose(%sess);
	
	unless(@kl)
	{
		unlink($CMSBuilder::Config::path_sess.'/'.$sessid.'.dir');
		unlink($CMSBuilder::Config::path_sess.'/'.$sessid.'.pag');
		unlink($CMSBuilder::Config::path_sess.'/'.$sessid.'.db');
	}
}


1;







