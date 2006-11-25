#!/usr/bin/perl
use strict;
use File::Find;

our @incs;
BEGIN { @incs = qw(./cmsbuilder/core ./cmsbuilder/modules) }

use Data::Dump qw(dump);
use ActivePerl::PPM::limited_inc;
use lib @incs;
use Tkx;

our @exts = qw/t/;
our $pat = '(\.'.join('$)|(\.',@exts).'$)';

our
(
	@all, $opts
);

sub var2f($$);
sub f2var($);


sub rtest
{
	return unless $_ =~ m/$pat/oi;
	
	push @all, $_;
}


sub select_tests
{
	$| = 1;
    
	my $i;
	
	my $mw = Tkx::widget->new(".", takeFocus => 1);
	for my $file (@all)
	{
		my $var = $file;
		$var =~ s/\W/_/g;
		
		Tkx::set($var, ! $opts->{$file});
		#warn $var . '->' . ! $opts->{$file};
		
		$i++;
		
		$mw->new_checkbutton
		(
			-text => "$file",
			-variable => $var,
			-indicatoron => 1,
			-command => sub { $opts->{$file} ? delete $opts->{$file} : ($opts->{$file} = 1)},
		)
		->g_pack(-fill => 'both');
	}
	
	$mw->new_label(-text => ' ')->g_pack;
	
	$mw->new_button
	(
		-text => "Cancel",
		-command => sub { $mw->g_destroy },
	)
	->g_pack;
	
	$mw->new_button
	(
		-text => "OK",
		-command => sub { save(); $mw->g_destroy; system('perl tests.pl') },
	)
	->g_pack;
	
	Tkx::focus(-force, '.');
	
	Tkx::MainLoop();
}


sub main
{
	#chdir('cmsbuilder');
	$opts = eval f2var 'select-tests.cfg';
	
	find({'wanted' => \&rtest, 'no_chdir' => 1}, './t');
	
	select_tests();
	
	return 0;
}

exit main();



#ÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑ



sub save
{
	var2f dump($opts), 'select-tests.cfg'
}


sub var2f($$)
{
	my $val = shift;
	my $fname = shift;
	
	my $fh;
	open($fh,'>',$fname);
	binmode($fh);
	print $fh $val;
	close($fh);
}


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