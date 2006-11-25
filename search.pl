#!/usr/bin/perl -w

use File::Find;
use Getopt::Std;
use strict;
use utf8;

our @exts = qw/cgi pl pm ehtml php tpl htaccess conf js css/;
our $pat = '(\.'.join('$)|(\.',@exts).'$)';
our $what;

our
(
	$dircnt,$i,$out,$cnt,$cfunc
);

$| = 1;

sub cnt { if($_ !~ m/$pat/oi){ return; } $dircnt++; }

sub compare
{
	return $_[0] =~ m/$what/
}

sub comparei
{
	return $_[0] =~ m/$what/i
}

sub p
{
	my($fh);
	
	if($_ !~ m/$pat/oi){ return; }
	
	open($fh,$_);
	
	if($i % int($dircnt/10) == 0){ print '.'; }
	
	my $strnum;
	my $f = 0;
	
	while(my $str = <$fh>)
	{
		$strnum++;
		
		if(&$cfunc($str))
		{
			unless($f){ $out .= "\n[${File::Find::dir}/$_]\n" }
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
	
	find({'wanted' => \&cnt, 'preprocess' => \&pps},'.');
	
	print "\nSearching for \"$what\" in $dircnt files  ";
	
	print '[';
	find({'wanted' => \&p, 'preprocess' => \&pps},'.');
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

sub pps
{
	return grep {$_ ne 'fckeditor' && $_ ne 'libperl'} @_;
}

sub main
{
	#print @ARGV,"\n";
	my $opts = {};
	getopt('irs', $opts);
	
	$cfunc = $opts->{i} ? \&comparei : \&compare;
	#print $opts->{i}, $opts->{i} ? 'comparei' : 'compare';
	
	while(1)
	{
		print 'Enter search string: ';
		my $str = <STDIN>;
		chomp($str);
		
		if(length($str))
		{
			$what = $str;
			$what =~ s#(\W)#\\$1#g unless $opts->{r};
		}
		
		search();
	}
}

main();
