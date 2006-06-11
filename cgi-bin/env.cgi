#!/usr/bin/perl
use strict qw(subs vars);

#BEGIN
#{
#	$ENV{'QUERY_STRING'} = $ENV{'REDIRECT_QUERY_STRING'};
#	require CGI;
#	import CGI 'param';
#}

print "Status: 200 OK\n";
print "Content-type: text/html\n\n";


for my $key (sort keys %ENV ){ print "$key = $ENV{$key}<br>"; }

print '<br><hr><br>';



#print 'x="',param('x'),'"';





1;