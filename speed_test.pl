
use strict qw(subs vars);

use LWP::Simple;
use Time::HiRes 'gettimeofday';

my $cnt = 20;
my $url = <>;

$| = 1;

do
{
	my $beg = gettimeofday();
	my $res;
	
	print '[';
	
	for my $i (1..$cnt)
	{
		$res = get($url);
		if(length($res))
		{ print '.'; }
		else
		{ print ' '; }
	}
	
	print ']';
	
	print "\n\nResult: ",int((gettimeofday() - $beg)*1000)/1000/$cnt,"\n\n";
}
while(map {$url = $_ ne "\n"?$_:$url} (<> || $url));


1;