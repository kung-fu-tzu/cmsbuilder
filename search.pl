use File::Find;

print 'Enter search string: '.$ARGV[0];
$what = $ARGV[0] || <>;
chomp($what);
print "\n\n";

$dircnt = 0;
$i = 1;
$| = 1;

sub cnt { $dircnt++; }

sub p
{
	open(F,$_);
	
	if($i % int($dircnt/10) == 0){ print '.'; }
	while($str = <F>)
	{
		if($str =~ m/$what/oi){ $cnt{$_}++; }
	}
	
	close(F);
	$i++;
}

find(\&cnt,'.');

print "Files: $dircnt\n";

print '[';
find(\&p,'.');
print ']';

print "\n\n";
for $key (keys %cnt)
{
	print $key,' [',$cnt{$key},"]\n";
}

if( $#{[keys(%cnt)]} < 0){ print "No results.\n"; }

print "\nDONE";

$x = <STDIN>;