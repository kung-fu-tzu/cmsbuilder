package JDBI::vtypes::miniword;
our @ISA = 'JDBI::VType';
# Миниворд #####################################################

sub table_cre
{
    return ' TEXT ';
}

sub aview
{
    my $class = shift;
    my $name = shift;
    my $val = shift;
    
    $val =~ s/\&/\&amp;/g;
    $val =~ s/\"/\&quot;/g;
    $val =~ s/\</\&lt;/g;
    $val =~ s/\>/\&gt;/g;
    $val =~ s/\n/\\n/g;
    $val =~ s/\r//g;
    
    my $ret = <<MINI;
    
    
   <script language="javascript">
   <!--
   var oFCKeditor ;
   oFCKeditor = new FCKeditor('$name');
   oFCKeditor.ToolbarSet = 'JLite' ;
   oFCKeditor.Width  = '100%' ;
   oFCKeditor.Height = 350 ;
   oFCKeditor.imagesFolder = "structure" ;
   oFCKeditor.attachFolder = "structure" ;
   oFCKeditor.Value  = "$val";
   oFCKeditor.Create() ;
   //-->
   </script>

MINI
    
    return $ret;
}

1;