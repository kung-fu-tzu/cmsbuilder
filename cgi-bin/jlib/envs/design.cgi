package EML::design;
use strict qw(subs vars);
my $w;


sub view_razd
{
    my $id = shift;
    
    my $razd = Razdel::new($id);
    my $len = $razd->len();
    my ($i,$to);
    
    if(!$razd->{'inroot'}){ $razd->des_tree(); }
    
    for($i=1;$i<=$len;$i++){
        
        $to = $razd->elem($i);
	
	if( $to->{'hidden'} ){
	    
	    if($main::gid != 0 and $to->{'creby'} != $main::uid){ next; }
	    
	}
        
        print '<br><table><tr><td>';
        
        $to->des_pre_view();
        
        print '</td></tr></table>';
        
    }
    
    if(!$to){ print '<br><br><center>Раздел пока пуст...</center>'; }
}

sub view_news
{
    my $id = shift;
    
    my $news = News::new($id);
    
    $news->des_tree();
    
    if( $news->{'hidden'} ){
	if($main::gid != 0 and $news->{'creby'} != $main::uid){ return; }
    }
    
    $news->des_self_view();

}

sub main_razd
{

    my $top = Razdel::new();

    my @a = $top->rlist();

    my $i;
    my ($it,$it_id);
    
    for $i (@a) {
        
        if(!$i->{'inroot'}){next;}
        
        $it = $i->name();
        $it_id = $i->{ID};
            
print <<ENDD;
            
            
<td>&nbsp;<a href="/razdel.ehtml?id=$it_id"><font class="title">.$it</font></a></td>
<td align="center"><img src="img/m3.jpg" width="3" height="27" hspace="5" align="absmiddle"></td>            
            
ENDD
            
    }



}


return 1;






