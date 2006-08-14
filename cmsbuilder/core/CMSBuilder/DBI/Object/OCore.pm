# CMSBuilder © Леонов П. А., 2005-2006

package CMSBuilder::DBI::Object::OCore;
use strict qw(subs vars);
use utf8;

sub _cname {'Объект (ядро)'}
sub _have_icon {0}
sub _dont_list_me {0};
sub _props {}
sub _aview {}
sub _one_instance {0}
sub _aview_tabs { ({-name => 'Данные элемента', -sub => 'admin_props'}, {-name => 'Дополнительно', -sub => 'admin_additional'}) }

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder;


#————————— Методы реализующие копирование объектов и создание ярлыков ——————————

sub shcut_cre
{
	my $o = shift;
	
	my $tsh;
	$tsh = ref($o)->cre();
	$tsh->{'SHCUT'} = $o->id;
	$tsh->save();
	
	return $tsh;
}

sub shcut_obj
{
	my $o = shift;
	
	return $o->{'SHCUT'}?ref($o)->new($o->{'SHCUT'}):undef;
}

sub copy
{
	my $o = shift;
	
	my $no = ref($o)->cre();
	return $o->copyto($no);
}

sub copyto
{
	my $o = shift;
	my $no = shift;
	
	my $p = $o->props();
	my $vt;
	
	my $noid = $no->id;
	
	for my $key (keys %$o)
	{
		if(exists $p->{$key})
		{
			$vt = 'CMSBuilder::DBI::vtypes::'.$p->{$key}{'type'};
			$no->{$key} = $vt->copy($key,$o->{$key},$o,$no);
		}
		else
		{
			$no->{$key} = $o->{$key};
		}
	}
	
	$no->{'ID'} = $noid;
	
	$no->save();
	
	return $no;
}


#————————————————— Методы реализации полноценного наследования —————————————————

sub one_instance { return $_[0]->_one_instance(@_); }

sub have_icon { return $_[0]->_have_icon(@_); }

sub dont_list_me { return $_[0]->_dont_list_me(@_); }

sub cname { return $_[0]->_cname(@_); }

sub aview
{
	my $c = ref($_[0]) || $_[0];
	my $buff = $c.'::_aview_buff';
	
	if($$buff){ return @$$buff; }
	
	my @t = cmsb_varr($c,'_aview',1);
	
	my @res;
	for my $v (reverse @t)
	{
		if($v eq '-'){ last; }
		unshift(@res,$v)
	}
	
	my $h = {};
	@res = grep {$h->{$_}?0:($h->{$_} = 1); } @res;
	
	$$buff = [@res];
	return @$$buff;
}

sub props
{
	my $c = ref($_[0]) || $_[0];
	my $buff = $c.'::_props_buff';
	
	if($$buff){ return $$buff; }
	
	$$buff = {cmsb_varr($c,'_props')};
	return $$buff;
}


#——————————————————————— Методы создания объектов Perl —————————————————————————

sub cre
{
	my $c = shift;
	
	my $o = {};
	bless($o,$c);
	
	$o->{'ID'} = $o->insert();
	$o->reload();
	
	return $o;
}

sub new
{
	my $c = shift;
	
	my $o = {};
	bless($o,$c);
	
	return $o->_init(@_);
}

sub _init
{
	my $o = shift;
	my $n = shift;
	
	unless($n){ return $o; }
	
	if($CMSBuilder::Config::do_dbo_cache)
	{
		my $sig = ref($o).$n;
		
		if(defined $CMSBuilder::dbo_cache{$sig})
		{
			return $CMSBuilder::dbo_cache{$sig};
		}
		$CMSBuilder::dbo_cache{$sig} = $o;
	}
	
	$o->{'ID'} = $n;
	$o->reload();
	
	return $o;
}

#———————————————————————————————————————————————————————————————————————————————

sub id
{
	my $o = shift;
	return $o->{'ID'} > 0 ? $o->{'ID'} : 0
}

sub myurl
{
	my $o = shift;
	
	my $cn = ref($o);
	#$cn =~ s#\:\:#\_#g;
	
	return $cn.($o->id?$o->id:'0');
}

sub name
{
	my $o = shift;
	my $ret;
	
	if($o->{'name'}){ return $o->{'name'} }
	unless($o->id){ return 'Объект не найден: '.$o->cname().' '.$o->id }
	
	return $o->cname().' '.$o->id;
}

sub papa
{
	my $o = shift;
	
	if($o->{'PAPA'})
	{
		return cmsb_url($o->{'PAPA'});
	}
	
	return undef;
}

sub root
{
	return $_[0]->papaN(0);
}

sub papaN
{
	my $o = shift;
	my $n = shift;
	
	my @path = $o->papa_path();
	
	if($n > $#path){ $n = $#path }
	
	return $path[$n];
}

sub isapapa
{
	my $o = shift;
	my $obj = shift;
	
	map {return 1 if $obj->myurl() eq $_->myurl()} $o->papa_path();
	
	return;
}

sub papa_path
{
	my $o = shift;
	my $n = shift;
	
	my(@path,$p,$cnt);
	
	$cnt = 0;
	$p = $o;
	
	while(($p = $p->papa()) && ($cnt <= 50))
	{
		die "to long papa_path: 50" if $cnt >= 50;
		$cnt++;
		push(@path,$p);
	}
	
	return reverse($o,@path);
}

sub owner
{
	my $o = shift;
	return cmsb_url($o->{'OWNER'}) || cmsb_url($CMSBuilder::Config::user_admin);
}

sub access
{
	return length($_[1]) == 1?1:0;
}

sub enum
{
	my $o = shift;
	
	my $papa = $o->papa();
	return undef unless $papa;
	return undef unless $papa->can('elem_tell_enum');
	
	return $papa->elem_tell_enum($o) || undef;
}

sub pname
{
	my $o = shift;
	
	my $papa = $o->papa();
	return unless $papa;
	return unless $papa->can('props');
	
	my $p = $papa->props;
	my $myurl = $o->myurl;
	
	map { return $_ if eval {$papa->{$_}->myurl eq $myurl}  } keys %$p;
	
	return;
}

sub elem_can_add { return 0; }


1;