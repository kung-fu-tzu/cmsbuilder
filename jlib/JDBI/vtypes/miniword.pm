package JDBI::vtypes::miniword;
our @ISA = 'JDBI::VType';
# Миниворд #####################################################

our $admin_own_html = 1;

sub table_cre
{
    return ' TEXT ';
}

sub aview
{
    my $class = shift;
    my $name = shift;
    my $val = shift;
    my $obj = shift;
    
    my $p = \%{ ref($obj).'::props' };
    
    $val =~ s/\&/\&amp;/g;
    $val =~ s/\"/\&quot;/g;
    $val =~ s/\</\&lt;/g;
    $val =~ s/\>/\&gt;/g;
    $val =~ s/\n/\\n/g;
    $val =~ s/\r//g;
    
    my $ret = '
    <tr><td colspan="2">
    '.$p->{$name}{'name'}.':</b><br>
    <script language="JavaScript">
    var '.$name.'_oFCKeditor;
    '.$name.'_oFCKeditor = new FCKeditor("'.$name.'");
    '.$name.'_oFCKeditor.ToolbarSet = "JLite";
    '.$name.'_oFCKeditor.Width  = "100%";
    '.$name.'_oFCKeditor.Height = 350;
    '.$name.'_oFCKeditor.Value  = "'.$val.'";
    '.$name.'_oFCKeditor.Create();
    </script>
    <br>
    </td></tr>
    ';
    
    return $ret;
}

1;