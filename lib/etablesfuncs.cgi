package JE;

sub err { print $_[0]; die $_[0]; }

sub ClassName
{
    my $obj = shift;
    my $cls = ref($obj);
    if(!$cls){ err '� ������� �������� ���������� �� ���. ��������'; }
    
    return $cls;
}



#ref










return 1;