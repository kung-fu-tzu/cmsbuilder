package design;
use strict qw(subs vars);

our $w;

sub init
{
    $JConfig::autosave = 0;
    
    my $url = JEML::parser()->{'path'};
    $url =~ s/\\|\///g;
    $w = '';
    if(!$url){ return; }
    
    $w = JDBI::url($url);
}

sub page
{
    unless($w){ return; }
    $w->des_page();
}

return 1;