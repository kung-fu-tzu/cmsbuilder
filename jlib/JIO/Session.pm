package JIO::Session;
use strict qw(subs vars);

our %sess;
our $sessid;

sub start
{
    my $dir = $JConfig::path_sess;
    
    my $cgi = $JIO::cgi || CGI->new();
    my %cook = $cgi->cookie( "JSession" );
    
    $sessid = $cook{"id"};
    $sessid =~ s/\D//g;
    
    if( length($sessid) < 30 ){
        
        srand();
        
        do{
            
            $sessid = rand().rand();
            $sessid =~ s/\D//g;
            
        }while(-f $dir.'/'.$sessid);
        
    }
    
    dbmopen(%sess,$dir.'/'.$sessid,0640) or die('SESSION_NOT_OPEN');
    
    $cook{'id'} = $sessid;
    
    my $dom = $ENV{'HTTP_HOST'};
    my @dom = split(/\./,$dom);
    
    if(@dom > 1){ $dom = '.'.$dom[$#dom-1].'.'.$dom[$#dom]; }else{ $dom = ''; }
    
    my $send = $cgi->cookie(
        -name=>"JSession",
        -value=>\%cook,
        -path=>'/',
        -expires=>'+365d',
        -domain=>$dom
    );
    
    print 'Set-Cookie: ',$send->as_string,"\n";
    return $send;
}

sub stop
{
    my $kl = (keys(%sess));
    dbmclose(%sess);
    
    if(!$kl){
        unlink($JConfig::path_sess.'/'.$sessid.'.dir');
        unlink($JConfig::path_sess.'/'.$sessid.'.pag');
        unlink($JConfig::path_sess.'/'.$sessid.'.db');
    }
}


return 1;







