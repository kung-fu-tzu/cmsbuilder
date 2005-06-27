# (с) Леонов П.А., 2005

package TimeMeter;
use strict qw(subs vars);
use Time::HiRes 'gettimeofday';

our($beg,$end,$dif);

sub begin
{
	$beg = gettimeofday();
	$end = $beg;
}

sub end
{
	$end = gettimeofday();
	$dif = $end - $beg;
	
	if($JConfig::print_timemeter)
	{
		print '<div style="POSITION:absolute; WIDTH:100%; LEFT:0px; TOP:5px" align="right"><b>',(int($dif*1000)/1000),'</b></div>';
		return $dif;
	}
}

sub telltime(&)
{
	my $code = shift;
	my $b = gettimeofday();
	&$code;
	print int((gettimeofday() - $b)*1000)/1000;
}

1;