use File::Find;

our @exts = qw/cgi pl pm ehtml js php tpl htaccess conf/;
our $pat = '(\.'.join('$)|(\.',@exts).'$)';
our $what;

our
(
	$dircnt,$i,$out,$cnt
);

$| = 1;

sub cnt { if($_ !~ m/$pat/oi){ return; } $dircnt++; }

sub p
{
	my($fh);
	
	if($_ !~ m/$pat/oi){ return; }
	
	open($fh,$_);
	
	if($i % int($dircnt/10) == 0){ print '.'; }
	
	my $strnum;
	my $f = 0;
	
	while($str = <$fh>)
	{
		$strnum++;
		
		if($str =~ m/$what/i)
		{
			unless($f){ $out .= "\n[$_]\n" }
			$f = 1;
			
			$cnt++;
			
			$out .= $strnum.'	'.$str;
		}
	}
	
	close($fh);
	$i++;
}

sub search
{
	$out = $cnt = '';
	$dircnt = 0;
	$i = 1;
	
	find(\&cnt,'.');
	
	print "\nSearching for \"$what\" in $dircnt files  ";
	
	print '[';
	find(\&p,'.');
	print ']';
	
	unless($cnt)
	{
		print "\n\n\n			NOTHING FOUND.";
	}
	else
	{
		print "\n",'-'x80,"\n$out\n",'-'x80,"\nMATHCES: $cnt";
	}
	
	print "\n\n\n";
}

sub main
{
	$what = $ARGV[0];
	
	while(1)
	{
		print 'Enter search string: '.$ARGV[0];
		my $str = <STDIN>;
		chomp($str);
		
		if(length($str))
		{
			$what = $str;
			$what =~ s#(\W)#\\$1#g;
		}
		
		search();
	}
}

main();
