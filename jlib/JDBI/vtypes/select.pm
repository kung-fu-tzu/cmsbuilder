package JDBI::vtypes::select;
our @ISA = 'JDBI::VType';
# Список ####################################################

sub table_cre
{
    my $class = shift;
    my %elem = %{$_[0]};
    my %vars = %{ $elem{'variants'} };
    
    return " ENUM( '".join("', '",keys(%vars))."' )  ";
}

sub aview
{
    my $class = shift;
    my $name = shift;
    my $val = shift;
    my $obj = shift;
    
    %props = $obj->props();
    %elem = %{ $props{$name} };
    
    my %vars = %{ $elem{'variants'} };
    my $var;
    my $ret = '<SELECT name="'.$name.'">';
    my $chkd = '';
    
    for $var (keys(%vars)){
	
	if($var eq $val){ $chkd = ' selected '; }else{ $chkd = ' '; }
	$ret .= '<OPTION '.$chkd.' value="'.$var.'">'.$vars{$var}.'</OPTION>';
    }
    
    $ret .= '</SELECT>';
    
    return $ret;
}

sub aedit
{
    my $class = shift;
    my $name = shift;
    my $val = shift;
    
    return $val;
}

1;