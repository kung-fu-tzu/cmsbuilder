#!/usr/bin/perl
use strict qw(subs vars);
use utf8;

BEGIN
{
	require '../cmsbuilder/Config.pm';
	print "Content-type: text/html; charset=utf-8\n\n";
	open(STDERR,'>&',STDOUT);
}

use CGI 'param';

our $fname = $CMSBuilder::Config::file_errorlog;
our $plen = 3072;

sub main
{
	binmode(STDOUT,':utf8');
	
	my $act = param('act');
	
	if($act eq 'clear')
	{
		clear_log();
		print '<p align="center"><a href="?">OK</a></p>';
		
		return;
	}
	
	my $page = param('page');
	
	print
	'
	<html>
	<head>
		<title>Лог ошибок билдера</title>
		<style>
		p
		{
			text-align: center;
		}
		p *
		{
			margin: 1em auto;
		}
		
		.log
		{
			white-space: wrap;
		}
		.error
		{
			margin: 1em 20%; padding: 0.5em;
			border: solid 1px #ffaaaa;
		}
		</style>
	</head>
	<body>
	<p><a href="?act=clear">Очистить</a></p>
	<p>
	',$page?('<a href="?page=',$page-1,'">&larr; Назад</a>&nbsp;&nbsp;&nbsp;'):'','
	<a href="?page=',$page+1,'">Далее &rarr;</a>
	</p>
	<pre class="log">
	';
	
	print_log($page);
	
	print
	'
	</pre>
	</body>
	</html>
	';
}

sub err
{
	my $text = shift;
	
	print '<div class="error">',$text,'</div>';
	
	return;
}

sub clear_log
{
	my $fh;
	open($fh,'>',$fname);
	#truncate(STDERR,0);
	truncate($fh,0);
	close($fh);
}

sub print_log
{
	my $p = shift;
	
	my $fh;
	open($fh,'<:utf8',$fname) || return err("Can`t open $fname: $!");
	binmode $fh;
	
	my $fsize = (stat $fh)[7];
	local $plen = $plen > $fsize ? $fsize : $plen;
	
	seek($fh,-1*$plen*($p+1),2) || return err("seek: $!");
	my $buff;
	read($fh,$buff,$plen) || ($! && return err("read: $!"));
	
	#$buff =~ s/\n/<br>\n/g;
	
	print $buff;
	#print join('<br>',<$fh>);
	
	close($fh) || return err("close: $!");
}


main();