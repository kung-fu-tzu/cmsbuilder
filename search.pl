use File::Find;

$what = 'Объект был удалён';
$dircnt = 0;
$i = 1;
$| = 1;

sub cnt
{
$dircnt++;
}

sub p
{
	open(F,$_);
	if($i % int($dircnt/10) == 0){ print '.'; }
	while($str = <F>)
	{
		if($str =~ m/$what/i){ $cnt{$_}++; }
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

print "\nOK";

$x = <>;