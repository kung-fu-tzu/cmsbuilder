package JDBI::Object;
use strict qw(subs vars);
our @ISA = ('JDBI::Access','JDBI::Base','JDBI::Admin','JDBI::OnEvents');
my $page = '/page.ehtml';


###################################################################################################
# Следующие методы находятся в разработке
###################################################################################################



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
	if($o->{'ID'} < 1){ return 'Объект не найдён: '.${ref($o).'::name'}.' '.$o->{'ID'} }
	
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

sub new
{
	my $class = shift;
	
	my $o = {};
	bless($o,$class);
	
	return $o->_init(@_);
}

sub _init
{
	my $o = shift;
	my $n = shift;
	
	unless($n){ return $o; }
	
	if($JConfig::do_dbo_cache){
		
		my $sig = ref($o).$n;
		
		if(defined $JDBI::dbo_cache{$sig}){
			return $JDBI::dbo_cache{$sig};
		}
		$JDBI::dbo_cache{$sig} = $o;
	}
	
	$o->{'ID'} = $n;
	$o->reload();
	
	return $o;
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

sub owner
{
	my $o = shift;
	return User->new($o->{'OID'});
}

sub enum
{
	my $o = shift;
	
	if(exists $o->{'_ENUM'}){ return $o->{'_ENUM'} }
	
	my $papa = $o->papa();
	unless($papa){ $o->{'_ENUM'} = 0; return 0; }
	unless($papa->type() eq 'Array'){ $o->{'_ENUM'} = 0; return 0; }
	
	$o->{'_ENUM'} = $papa->elem_tell_enum($o);
	
	return $o->{'_ENUM'};
}

sub as_string
{
	my $o = shift;
	return $o->myurl();
}

sub type { return 'Object'; }

use overload ('""' => \&as_string);

return 1;

