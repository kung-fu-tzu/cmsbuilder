package JE;

sub err { print $_[0]; die $_[0]; }

sub ClassName
{
    my $obj = shift;
    my $cls = ref($obj);
    if(!$cls){ err 'В функцию передана переменная не явл. объектом'; }
    
    return $cls;
}



#ref










return 1;