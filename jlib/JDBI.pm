use DBI;
use CGI();
use JDBI::Object;
use Classes::User;
use Classes::UserGroup;
#use JDBI::Array;

package JDBI;
use strict qw(subs vars);

our $err505 = sub { print "Content-type: text/html\n\n505<br>".join('<br>',@_); };
our $err404 = sub { print "Content-type: text/html\n\n404<br>".join('<br>',@_);; };
our $err403 = sub { print "Content-type: text/html\n\n403<br>".join('<br>',@_);; };

our $dbh;
our %dbo_cache;
our %vtypes;
our $cgi;
our @vtypes  = qw( checkbox date file formula int microword miniword object password radio select string text time timestamp vstring );
our @classes = qw( Elem User UserGroup UserRoot Dir Papa );

my $user;
my $group;

sub init
{
    $dbh = '';
    $cgi = '';
    %dbo_cache = ();
    %vtypes = ();
    $user = '';
    $group = '';
    
    $cgi = CGI->new();
    
    my $vt;
    for $vt (@vtypes){ require 'JDBI/vtypes/'.$vt.'.cgi'; }
    
    my $class;
    for $class (@classes){ require 'Classes/'.$class.'.pm'; }
}

sub connect
{
    my($dbd,$u,$p) = @_;
    $dbh = DBI->connect($dbd,$u,$p,{ RaiseError => 1 });
    $dbh->{'HandleError'} = $err505;
}

sub dousers
{
    my($do) = shift;
    
    if($do){
        
        # Whenever...
        
    }else{
        
        $user  = User->new();
        $user->{'ID'} = 1;
        $user->{'name'} = 'Монопольный доступ';
        
        $group = UserGroup->new();
        $group->{'ID'} = 1;
        $group->{'name'} = 'Администраторы';
        $group->{'html'} = 1;
        $group->{'cms'} = 1;
        $group->{'root'} = 1;
    }
}

sub user  { return $user->no_cache(); }
sub group { return $group->no_cache(); }


####################################################################################

####################################################################################

sub err505 { $err505->(@_) }
sub err404 { $err404->(@_) }
sub err403 { $err403->(@_) }

sub classOK { return 1; }


####################################################################################

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

sub url
{
    my $url = shift;
    
    my ($class,$id) = url2classid($url);
    
    my $to = &{$class.'::new'}($id);
    
    return $to;
}

sub url2classid
{
    my $url = shift;
    
    my ($class,$id) = ('','');
    
    if( $url !~ m/^([A-Za-z]+)(\d+)$/ ){ JDBI::err505('Invalid object requested: '.$url); }
    
    $class = $1;
    $id = $2;
    
    if( !JDBI::classOK($class) ){ JDBI::err505('Invalid class name requested: '.$class); }
    
    return ($class,$id);
}

sub url
{
    my $url = shift;
    
    my ($class,$id) = url2classid($url);
    
    my $to = &{$class.'::new'}($id);
    
    return $to;
}

sub url2classid
{
    my $url = shift;
    
    my ($class,$id) = ('','');
    
    if( $url !~ m/^([A-Za-z]+)(\d+)$/ ){ JDBI::err505('Invalid object requested: '.$url); }
    
    $class = $1;
    $id = $2;
    
    if( ! JDBI::classOK($class) ){ JDBI::err505('Invalid class name requested: '.$class); }
    
    return ($class,$id);
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

return 1;



