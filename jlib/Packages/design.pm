package design;
use strict qw(subs vars);

our $w;

sub init
{
    my $url = $eml::path;
    $url =~ s/\\|\///g;
    $w = '';
    if(!$url){ return; }
    
    $w = DBObject::url($url);
}

sub page
{
    $w->des_page();
}


return 1;






