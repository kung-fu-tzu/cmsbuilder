package JDBI::vtypes::time;
our @ISA = 'JDBI::VType';
# Время ####################################################

sub table_cre
{
    return ' TIME ';
}

sub aview
{
    my $class = shift;
    my $name = shift;
    my $val = shift;
    my $ret;
    
    my @a = split(/\:/,$val);
    
    if($a[0] < 1){$a[0] = ''}
    if($a[1] < 1){$a[1] = ''}
    if($a[2] < 1){$a[2] = ''}
    
    $ret = "<input cols=4 style='WIDTH: 20px' type=text name='${name}_h' value=\"$a[0]\">";
    $ret .= "<input cols=4 style='WIDTH: 20px' type=text name='${name}_m' value=\"$a[1]\">";
    $ret .= "<input cols=6 style='WIDTH: 20px' type=text name='${name}_s' value=\"$a[2]\">";
    
    return $ret;
}

sub aedit
{
    my $class = shift;
    my $name = shift;
    my $val;
    
    my $h = eml::param($name.'_h');
    my $m = eml::param($name.'_m');
    my $s = eml::param($name.'_s');
    
    $val = $h.':'.$m.':'.$s;
    
    return $val;
}

1;