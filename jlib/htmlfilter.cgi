

sub HTMLfilter
{
    my $val = shift;
    
    $val =~ s/</&lt;/g;
    $val =~ s/>/&gt;/g;
    
    return $val;
}

1;