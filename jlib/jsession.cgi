package JSession;
use strict qw(subs vars);

sub start
{
    
    my $co = new CGI;
    my %cook = $co->cookie( "JSession" );
    
    my $sessid = $cook{"id"};
    
    if( length($sessid) < 10 ){
        
        do{
            
            srand();
            
            $sessid = rand().rand();
            $sessid =~ s/\D//g;
            
        }while(-f $eml::sess_dir.'/'.$sessid);
        
    }
    
    #tie( %sess, "DB_File", $eml::sess_dir.'/'.$sessid, O_RDWR|O_CREAT, 0640, $DB_HASH );
    $eml::sess{'aaa'} = 234;
    dbmopen(%eml::sess,$eml::sess_dir.'/'.$sessid,0640) or die 'SESSION_NOT_OPEN';
    
    #$sess{'sid'} = $sessid;
    
    
    $cook{"id"} = $sessid;
    
    my $send = $co->cookie(
            -name=>"JSession",
            -value=>\%cook,
            -path=>'/',
            -expires=>'+365d'    
    );
    
    print 'Set-Cookie: ',$send->as_string,"\n";
    
}

sub stop
{
    
    dbmclose(%eml::sess);
    #print 'stop';
    
    
}


return 1;







