use File::Find;

$what = '	';
$dircnt = 0;
$i = 1;
$| = 1;

sub cnt
{
$dircnt++;
}

sub p
{
	if($i % int($dircnt/10) == 0){ print '.'; }
	$i++;
	
	if($_ eq 'space2tab.pl'){ next; }
	
	open(F,$_);
	$f = join('',<F>);
	close(F);
	$f =~ s/    /	/g;
	open(F,'> '.$_);
	print F $f;
	close(F);
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

print "\nOK";

$x = <>;