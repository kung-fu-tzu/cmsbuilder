# 
# Модуль управляет буферизацией вывода
# и определяет функции стандартных ошибок.
# 

package JIO;
use strict qw(subs vars);
use Exporter;
use Carp;
use JIO::Session;
use POSIX ('strftime');

our @EXPORT = ('err505','err404','err403','sess');
our @ISA = 'Exporter';

our $out;
our $cgi;

local *MEM;


###################################################################################################
# Рабочие функции интерфейса
###################################################################################################

sub err505
{
    clear();
    stop();
    print '505';
    croak 'Error 505: '.join('',@_);
}

sub err404
{
    clear();
    stop();
    print '404';
    croak 'Error 404: '.join('',@_);
}

sub err403
{
    clear();
    stop();
    print '403';
    croak 'Error 403: '.join('',@_);
}

sub start
{
    # Заголовки
    my $str_time = strftime('%a, %d %b %Y %T %H:00:00 GMT',gmtime( time()+200 ));
    
    print "Content-type: text/html; charset=windows-1251\n";
    print "Pragma: no-cache\n";
    print "Cache-control: max-age=0\n";
    print "Last-Modified: $str_time\n";
    print "Expires: 0\n";
    
    $cgi = CGI->new();
    
    JIO::Session->start();
    
    print "\n\n";
    
    if($JConfig::buff_do){
        if($JConfig::buff_mem){
            open(MEM,'>',\$out);
        }else{
            open(MEM,'>'.$JConfig::path_tmp.'/out'.$$.'.tmp');
        }
        
        select(MEM);
    }
    
}

sub sess { return \%JIO::Session::sess; }

sub clear
{
    if($JConfig::buff_do){
        
        select STDOUT;
        close MEM;
        
        if($JConfig::buff_mem){
            $out = '';
            open(MEM,'>',\$out);
        }else{
            open(MEM,'>out'.$$.'.tmp');
        }
        
        select MEM;
    }
}

sub stop
{
    JIO::Session->stop();
    
    if($JConfig::buff_do){
        
        select(STDOUT);
        close MEM;
        
        if($JConfig::buff_mem){
            
        }else{
            open(MEM,'<out'.$$.'.tmp');
            $out = join('',<MEM>);
            close MEM;
            
            unlink('out'.$$.'.tmp');
        }
        
        $out =~ s/\n/\r\n/g;
        print $out;
        $out = '';
    }
}

return 1;



