# (с) Леонов П.А., 2005

package JDBI::Object;
use strict qw(subs vars);
our @ISA = ('JDBI::Base','JDBI::Access','JDBI::Tree','JDBI::Admin','JDBI::RPC','JDBI::OnEvents');

sub _cname {'Объект'}
sub _page_ehtml {'/page.ehtml'}
sub _have_icon {1}
sub _props {}
sub _aview {}

#-------------------------------------------------------------------------------


###################################################################################################
# Следующие методы находятся в разработке
###################################################################################################

sub page_ehtml { return $_[0]->_page_ehtml(@_); }
sub have_icon { return $_[0]->_have_icon(@_); }
sub cname { return $_[0]->_cname(@_); }

sub aview
{
	my $c = ref($_[0]) || $_[0];
	my $buff = $c.'::_aview_buff';
	
	if($$buff){ return @$$buff; }
	
	my @t = varr($c,'_aview');
	
	my @res;
	for my $v (reverse @t)
	{
		if($v eq '-'){ last; }
		unshift(@res,$v)
	}
	
	$$buff = [@res];
	return @$$buff;
}

sub props
{
	my $c = ref($_[0]) || $_[0];
	my $buff = $c.'::_props_buff';
	
	if($$buff){ return $$buff; }
	
	$$buff = {varr($c,'_props')};
	return $$buff;
}

sub varr
{
	my $c = shift;
	my $var = shift;
	my @sv;
	
	for my $pc (reverse @{$c.'::ISA'})
	{
		push(@sv,varr($pc,$var));
	}
	
	if(*{$c.'::'.$var}{'CODE'}){ push(@sv,&{$c.'::'.$var}); }
	
	return @sv;
}

###################################################################################################
# Методы вывода данных в дизайн
###################################################################################################

sub file_href
{
	my $o = shift;
	my $name = shift;
	my $id = $o->{'ID'};
	
	return $JConfig::http_wwfiles.'/'.$o->myurl().'_'.$name.'.'.$o->{$name};
}


###################################################################################################
# Методы создания объектов Perl
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
	
	if($JConfig::do_dbo_cache)
	{
		my $sig = ref($o).$n;
		
		if(defined $JDBI::dbo_cache{$sig})
		{
			return $JDBI::dbo_cache{$sig};
		}
		$JDBI::dbo_cache{$sig} = $o;
	}
	
	$o->{'ID'} = $n;
	$o->reload();
	
	return $o;
}


###################################################################################################
# Дополнительные методы
###################################################################################################

sub papa
{
	my $o = shift;

	if($o->{'PAPA_CLASS'} eq '' or $o->{'PAPA_ID'} < 1){ return undef; }
	return( $o->{'PAPA_CLASS'}->new($o->{'PAPA_ID'}) );
}

sub papaN
{
	my $o = shift;
	my $n = shift;
	my @tree;
	
	my $count = 0;
	
	do
	{
		$count++;
		unshift(@tree, $o);
	}
	while($o = $o->papa() and $count < 50);
	
	if($n > $#tree){ $n = $#tree }
	
	return $tree[$n];
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

sub elem_can_add { return 0; }

sub type { return 'Object'; }

use overload ('""' => \&as_string);


1;