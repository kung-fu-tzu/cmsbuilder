package JDBI::vtypes::text;
our @ISA = 'JDBI::VType';
# Текст #####################################################

sub table_cre
{
    return ' TEXT ';
}

sub aedit
{
    my $class = shift;
    my $name = shift;
    my $val = shift;
    
    $val =~ s/\r\n/\n/g;
    $val =~ s/\r//g;
    $val =~ s/\n/<br>/g;
    
    return $val;
}

sub aview
{
    my $class = shift;
    my $name = shift;
    my $val = shift;
    
    $val =~ s/<br>/\n/g;
    
    $val =~ s/\&/\&amp;/g;
    $val =~ s/\"/\&quot;/g;
    $val =~ s/\</\&lt;/g;
    $val =~ s/\>/\&gt;/g;
    
    my $ret = '<textarea class="winput" cols=42 rows=15 name="'.$name.'">'.$val.'</textarea>';
    
    return $ret;
}

1;