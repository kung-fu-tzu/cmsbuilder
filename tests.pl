#!/usr/bin/perl
use strict qw(subs vars);
use File::Find;

our @incs;
BEGIN { @incs = qw(./core ./modules) }

use lib @incs;

our @exts = qw/pl/;
our $pat = '(\.'.join('$)|(\.',@exts).'$)';

our($total,$cntok);


sub rtest
{
	return unless $_ =~ m/$pat/oi;
	
	print "$_: ";
	
	my $path = $_;
	$path =~ s$/$\\$g;
	
	my $incs = join ' ', map {"-I$_"} @incs;
	
	my $res = qx(perl $incs @ARGV "$path" 2>&1); #1>nul 2>tests.log
	my $rt = $? ? "FAILED\n$res\n\n" : 'OK';
	
	print "		$rt\n";
	
	#map { print eval {&$_();} ? 'OK' : "failed: $@","\n" } map {print $_,': '; $tests->{$_}} keys %$tests;
	
	$cntok++ unless $?;
	$total++;
}

sub main
{
	chdir('cmsbuilder');
	
	($total,$cntok) = ('000') x 2;
	
	find({'wanted' => \&rtest, 'no_chdir' => 1},'./t');
	
	print "\n\n";
	print "Success!\n\n" if $cntok eq $total;
	print "DONE: $cntok/$total";
	
	if($cntok eq $total){ sleep(1); }
	else{ <STDIN>; }
}

main();


1;