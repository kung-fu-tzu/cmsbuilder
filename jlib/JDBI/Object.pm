package JDBI::Object;
use strict qw(subs vars);
our @ISA = ('JDBI::Admin','JDBI::Access');
our $AUTOLOAD;
my %vtypes;
my $page = '/page.ehtml';


###################################################################################################
# Следующие методы находятся в разработке
###################################################################################################

sub owner
{
    my $o = shift;
    return User->new($o->{'OID'});
}

sub check
{
    my $class = shift;
    
    my $p = \%{ $class.'::props' };
    
    my $i;
    for $i (0 .. $#{$class.'::aview'}){
	
	if(!$p->{${$class.'::aview'}[$i]}){
	    print STDERR "\n",'@'.$class.'::aview contain prop ',${$class.'::aview'}[$i],' not existed in %'.$class.'::props.',"\n";
	    splice(@{$class.'::aview'},$i,1)
	}
    }
    
    #print STDERR '[@'.$class.'::aview checked]';
}

sub enum
{
    my $o = shift;
    
    return $o->{'_ENUM'};
}

###################################################################################################
# Методы вывода данных в дизайн
###################################################################################################

sub des_tree
{
    my $o = shift;
    
    my @all;
    my $count = 0;
    
    unshift(@all,$o->name());
    
    while($o = $o->papa() and $count < 50){
	$count++;
	unshift(@all, $o->des_name());
    }
    
    print join(' :: ',@all);
}

sub des_page
{
    my $o = shift;
    
    print '<b>',$o->{'name'},'</b> Страничный вывод для класса "',ref($o),'" не определён!';
}

sub des_title
{
    my $o = shift;
    return $o->name();
}

sub des_preview
{
    my $o = shift;
    
    print '<b>',$o->{'name'},'</b> Предварительный вывод для класса "',ref($o),'" не определён!';
}

sub des_href
{
    my $o = shift;
    my $page = shift;
    
    return ${ref($o).'::page'}.'/'.$o->myurl();
}

sub des_name
{
    my $o = shift;
    
    my $dname = $o->{'name'};
    if(!$dname){ $dname = ${ref($o).'::name'}; }
    
    return '<a href="'.$o->des_href().'">'.$dname.'</a>';
}

sub name
{
    my $o = shift;
    my $ret;
    
    if($o->{'name'}){ return $o->{'name'} }
    if($o->{'ID'} < 1){ return 'Объект был удалён: '.${ref($o).'::name'}.' '.$o->{'ID'} }
    
    return ${ref($o).'::name'}.' '.$o->{'ID'};
}

sub file_href
{
    my $o = shift;
    my $name = shift;
    my $id = $o->{'ID'};
    
    return $JConfig::http_wwfiles.'/'.$o->myurl().'_'.$name.'.'.$o->{$name};
}


###################################################################################################
# Методы для реализации наследования Perl
###################################################################################################

sub new
{
    my $class = shift;
    
    my $o = {};
    bless($o,$class);
    
    return $o->_init(@_);
}

sub cre
{
    my $class = shift;
    
    my $o = {};
    bless($o,$class);
    
    $o->{'ID'} = $o->insert();
    $o->access_set('rw');
    $o->reload();
    
    return $o;
}

sub _init
{
    my $o = shift;
    my $n = shift;
    my $no_cache = shift;
    
    if(!$n){ return $o; }
    
    if($JDBI::dbo_cache{JDBI->user()->{'ID'}.ref($o).$n}){
	$o->{'ID'} = 0;
	return $JDBI::dbo_cache{JDBI->user()->{'ID'}.ref($o).$n};
    }
    
    $o->load($n);
    
    $JDBI::dbo_cache{JDBI->user()->{'ID'}.ref($o).$o->{'ID'}} = $o;
    
    return $o;
}

sub DESTROY
{
    my $o = shift;
    #if($o->{'_modifide'}){ $o->save(); }
    $o->save();
    #print 'DESTROY: '.$o->myurl();
}

sub AUTOLOAD1
{
    my $o = shift;
    my $val = shift;
    
    my $func = $AUTOLOAD;
    $func =~ s/.*:://;
    
    my %p = %{ ref($o).'::props' };
    if( !exists($p{$func}) ){ JIO::err505('JDBI::Object::AUTOLOAD : Call an undefined function "'.$AUTOLOAD.'", from object url = '.$o->myurl()); }
    
    if($val){
	$o->{$func} = $val;
	$o->{'_modifide'} = 1;
	return $val;
    }else{
	return $o->{$func};
    }
}


###################################################################################################
# Методы контроля ошибок
###################################################################################################

sub err_add
{
    my $o = shift;
    my $errstr = shift;
    
    if(!$o->{'_errors'}){ $o->{'_errors'} = (); }
    
    push(@{ $o->{'_errors'} }, $errstr);
}

sub err_print
{
    my $o = shift;
    my $errstr;
    
    for $errstr ( @{ $o->{'_errors'} } ){ print $errstr,'<br>' }
}

sub err_is
{
    my $o = shift;
    
    return ($#{ $o->{'_errors'} } < 0) ? 0 : 1;
}


###################################################################################################
# Дополнительные методы
###################################################################################################

sub type { return 'Object'; }

sub no_cache
{
    my $o = shift;
    
    my $no = ref($o)->new();
    $no->load($o->{'ID'});
    $no->{'_temp_object'} = 1;
    
    return $no;
}

sub myurl
{
    my $o = shift;
    
    return ref($o).$o->{'ID'};
}

sub papa
{
    my $o = shift;
    
    if($o->{'PAPA_CLASS'} eq '' or $o->{'PAPA_ID'} < 1){ return undef; }
    
    return( $o->{'PAPA_CLASS'}->new($o->{'PAPA_ID'}) );
}

return 1;

