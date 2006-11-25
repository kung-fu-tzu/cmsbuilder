#!/usr/bin/perl
use strict;
use File::Find;
use Getopt::Std;

our @incs;
BEGIN { @incs = qw(./cmsbuilder/core ./cmsbuilder/modules) }

use lib @incs;

our @exts = qw/t/;
our $pat = '(\.'.join('$)|(\.',@exts).'$)';

our
(
	$total, $cntok, $skiped, $failed, $opts
);

getopt('a', my $co = {});

sub f2var($);

sub rtest
{
	return unless $_ =~ m/$pat/oi;
	unless (exists $co->{a})
	{
		return if $opts->{$_};
	}
	
	printf '%-60s', "$_: ";
	
	my $path = $_;
	$path =~ s$/$\\$g if $^O =~ /mswin/;
	
	my $incs = join ' ', map {"-I$_"} @incs;
	
	#my $res = system("perl $incs @ARGV \"$path\" 2>&1");
	my $res = qx(perl $incs @ARGV "$path" 2>&1); #1>nul 2>tests.log
	my $rt;
	
	if ($? >> 8 == 254)
	{
		$rt = 'SKIPED';
		$skiped++;
	}
	else
	{
		if ($?)
		{
			$res =~ s/(^|\n+)/$1	/gs;
			$rt = "FAILED" . ($res && "\n$res");
			$failed++;
		}
		else
		{
			$rt = 'OK';
			$cntok++;
		}
	}
	
	print "$rt\n";
	
	$total++;
}

sub main
{
	#chdir('cmsbuilder');
	
	$opts = eval f2var 'select-tests.cfg';
	
	($total,$cntok) = ('000') x 2;
	#warn $co->{a};
	find({'wanted' => \&rtest, 'no_chdir' => 1},'./t');
	
	print "Success!\n" unless $failed;
	
	print "DONE: $cntok/$total";
	print " FAILED: $failed" if $failed;
	print " SKIPED: $skiped" if $skiped;
	
	#if($cntok eq $total){ sleep(1); }
	#else{ <STDIN>; }
	
	return $failed;
}

exit main();



#ÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑ



sub f2var($)
{
	my $fname = shift;
	local $/ = undef;
	
	my $fh;
	open($fh,'<',$fname);
	binmode($fh);
	my $val = <$fh>;
	close($fh);
	
	return $val;
}


1;