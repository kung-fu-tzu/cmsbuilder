# Миниворд #####################################################

$vtypes{'miniword'}{table_cre} = sub {
    
    return ' TEXT ';
};

$vtypes{'miniword'}{'aview'} = sub {

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
};

1;