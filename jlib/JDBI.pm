use DBI;
use CGI 'param';
use JDBI::VType;
use JDBI::Access;
use JDBI::Base;
use JDBI::Admin;
use JDBI::Object;
use JDBI::Array;
use Classes::User;
use Classes::UserGroup;

package JDBI;
use strict qw(subs vars);
use Exporter;


###################################################################################################
# Базовые переменные интерфейса
###################################################################################################

our @EXPORT = ('url','user','group');
our @ISA = 'Exporter';

our $dbh;
our %dbo_cache;
our %vtypes;
our $cgi;
our @vtypes;
our @classes;

our $user;
our $group;


###################################################################################################
# Конфигурационные функции интерфейса
###################################################################################################

sub init()
{
    $dbh = '';
    $cgi = '';
    %dbo_cache = ();
    %vtypes = ();
    @classes = ();
    @vtypes = ();
    $user = '';
    $group = '';
    
    $cgi = $JIO::cgi || CGI->new();
    
    my $cdir;
    my $file;
    
    # Собираем информацию о виртуальных типах.
    opendir($cdir,$JConfig::path_lib.'/JDBI/vtypes');
    while($file = readdir($cdir)){
        unless(-f $JConfig::path_lib.'/JDBI/vtypes/'.$file){ next; }
        unless($file =~ m/^\w+\.pm$/){ next; }
        
        $file =~ s/\.pm//g;
        push @vtypes, $file;
    }
    closedir($cdir);
    
    my $vt;
    for $vt (@vtypes){ require 'JDBI/vtypes/'.$vt.'.pm'; }
    
    # Собираем информацию о имеющихся классах.
    opendir($cdir,$JConfig::path_lib.'/Classes');
    while($file = readdir($cdir)){
        unless(-f $JConfig::path_lib.'/Classes/'.$file){ next; }
        unless($file =~ m/^\w+\.pm$/){ next; }
        
        $file =~ s/\.pm//g;
        push @classes, $file;
    }
    closedir($cdir);
    
    
    my $class;
    for $class (@classes){ require 'Classes/'.$class.'.pm'; }
    for $class (@classes){ if($class->can('onload')){ $class->onload(); } }
    if($JConfig::debug){ for $class (@classes){ if($class->can('check')){ $class->check(); } } }
}

sub destruct()
{
    %dbo_cache = ();
    
    $dbh->disconnect();
}

sub connect
{
    my $class = shift;
    my($dbd,$u,$p);
    
    if(@_){
        ($dbd,$u,$p) = @_;
    }else{
        ($dbd,$u,$p) = ($JConfig::mysql_base,$JConfig::mysql_user,$JConfig::mysql_pas);
    }
    
    $dbh = DBI->connect($dbd,$u,$p,{ RaiseError => 1 });
    $dbh->{'HandleError'} = \&JIO::err505;
}

sub dousers()
{
    if($JConfig::users_do){
        
        # Whatever...
        
    }else{
        
        $user  = User->new();
        $user->{'ID'} = 1;
        $user->{'name'} = 'Монопольный режим';
        $user->{'_temp_object'} = 1;
        
        $group = UserGroup->new();
        $group->{'ID'} = 1;
        $group->{'name'} = 'Администраторы';
        $group->{'html'} = 0;
        $group->{'cms'} = 1;
        $group->{'root'} = 1;
        $group->{'_temp_object'} = 1;
    }
}

sub user()  { return $user; }
sub group() { return $group; }


###################################################################################################
# Базовые функции интерфейса
###################################################################################################

sub print_props
{
    my $class = shift;
    my $key;
    my %p = $class->props();
    
    print '<table border=1>';
    
    print '<tr><td align=center colSpan=2><b>'.$class.'</b></td></tr>';
    
    for $key (keys( %p )){
        print '<tr><td>',$p{$key}{'name'},' (',$key,'):</td><td><b>',$p{$key}{'type'},'</b></td></tr>';
    }
    
    print '</table>';
    
    return '';
}

sub url($)
{
    my $url = shift;
    
    my ($class,$id) = url2classid($url);
    
    my $to = $class->new($id);
    
    return $to;
}

sub url2classid
{
    my $url = shift;
    
    my ($class,$id) = ('','');
    
    if( $url !~ m/^([A-Za-z]+)(\d+)$/ ){ JIO::err505('Invalid object requested: '.$url); }
    
    $class = $1;
    $id = $2;
    
    if( !JDBI::classOK($class) ){ JIO::err505('Invalid class name requested: '.$class); }
    
    return ($class,$id);
}

sub classOK
{
    my $cn = shift;
    my $i = '';
    
    for $i (@JDBI::classes){ if($i eq $cn ){ return 1; } }
    
    return 0;
}

sub fromTIMESTAMP
{
    my $ts = shift;
    
    my $str = $JDBI::dbh->prepare('SELECT DATE_FORMAT(?,\'%d %M %Y г., %H:%i:%s\')');
    $str->execute($ts);
    
    my $date;
    ($date) = $str->fetchrow_array();
    
    $date =~ s/^0//;
    
    $date =~ s/January/Января/i;
    $date =~ s/February/Февраля/i;
    $date =~ s/March/Марта/i;
    $date =~ s/April/Апреля/i;
    $date =~ s/May/Мая/i;
    $date =~ s/June/Июня/i;
    $date =~ s/July/Июля/i;
    $date =~ s/August/Августа/i;
    $date =~ s/September/Сентября/i;
    $date =~ s/October/Октября/i;
    $date =~ s/November/Ноября/i;
    $date =~ s/December/Декабря/i;
    
    return $date;
}

sub access_creTABLE
{
    my $sql = 'CREATE TABLE IF NOT EXISTS `access` ( '."\n";
    $sql .= '`ID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY , ';
    $sql .= '`url` VARCHAR(50) NOT NULL, ';
    $sql .= '`memb` VARCHAR(50) DEFAULT \'\' NOT NULL, ';
    $sql .= '`code` VARCHAR(20) DEFAULT \'\' NOT NULL, ';
    $sql .= 'INDEX ( `memb` ), INDEX ( `url` ) )';
    
    my $str = $JDBI::dbh->prepare($sql);
    $str->execute();
}

sub creTABLE
{
    my $class = shift;
    my $key;
    my %p;
    
    %p = %{$class.'::props'};
    
    print '<br><a onclick="sql_',$class,'.style.display = \'block\'; return false;" href="open">+</a> <b>Создание таблицы для класса "',$class,'":</b><br>';
    
    my $sql = 'CREATE TABLE IF NOT EXISTS `dbo_'.$class.'` ( '."\n";
    $sql .= '`ID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY , '."\n";
    $sql .= '`OID` INT DEFAULT \'-1\' NOT NULL, '."\n";
    $sql .= '`ATS` TIMESTAMP NOT NULL, '."\n";
    $sql .= '`CTS` TIMESTAMP NOT NULL, '."\n";
    $sql .= '`PAPA_ID` INT DEFAULT \'0\' NOT NULL, '."\n";
    $sql .= '`PAPA_CLASS` VARCHAR(20) NOT NULL, '."\n";
    
    for $key (keys(%p)){
        if($vtypes{ $p{$key}{'type'} }{'table_cre'}){
            $sql .= " `$key` ".$vtypes{ $p{$key}{'type'} }{'table_cre'}->($p{$key}).' NOT NULL , '."\n";
        }
    }
    $sql =~ s/,\s*$//;
    $sql .= "\n )";
    
    my $str = $JDBI::dbh->prepare($sql);
    $str->execute();
    
    $sql =~ s/\n/<br>\n/g;
    
    print '<div style="DISPLAY: none" id="sql_',$class,'">',$sql,'</div>';
}

sub purge_cache { %JDBI::dbo_cache = (); }

sub dump_cache
{
    my $obj;
    my $file;
    open($file,'>'.$JConfig::path_tmp.'/cache.html');
    print $file '<HTML><BODY><TITLE>Содержимое %JDBI::dbo_cache, для процесса с PID = ',$$,'</TITLE><TABLE border=1>';
    print $file '<TR><TD><b>url</d></TD><TD><b>name</b></TD><TD><b>addres</b></TD></TR>';
    for $obj (keys(%JDBI::dbo_cache)){
        print $file '<TR><TD>',$obj,'</TD><TD>',$JDBI::dbo_cache{$obj}->name(),'</TD><TD>',$JDBI::dbo_cache{$obj},'</TD></TR>';
    }
    print $file '</TABLE></BODY></HTML>';
    close($file);
}

sub HTMLfilter
{
    my $val = shift;
    
    $val =~ s/</&lt;/g;
    $val =~ s/>/&gt;/g;
    
    return $val;
}

sub MD5
{
    my $var = shift;
    
    my $str = $dbh->prepare('SELECT MD5(?)');
    $str->execute($var);
    
    my ($res) = $str->fetchrow_array();
    return $res;
}

###################################################################################################

return 1;



