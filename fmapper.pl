use File::Find;
use strict qw(subs vars);

my @exts = qw/cgi txt pl pm js ehtml/;

print STDERR 'Mapping...';

open(OUT,'> fmap.txt');
select(OUT);

print "\n\n";

my $out = '';
my $fcnt = 0;
my $str = '';
my $pat = '('.join(')|(',@exts).')$';

sub p
{
	if($_ !~ m/$pat/oi){ next; }
	
	$out = '';
	
	open(F,$_);
	while($str = <F>)
	{
		if($str =~ m/sub\s+([\w]+)/){ $out .= $1."\n"; }
	}
	close(F);
	
	if($out)
	{
		$fcnt++;
		print '############## ',$_,"\n",$out,"\n\n";
	}
}

find(\&p,'.');


print "\n\n\nFiles: $fcnt;\nDONE";