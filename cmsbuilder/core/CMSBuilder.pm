# CMSBuilder © Леонов П. А., 2005-2006

package CMSBuilder;
use strict;
require 5.8.2;
use utf8;

use Exporter;
our @ISA = 'Exporter';
our @EXPORT = qw
(
	$cmsb_error
	
	&cmsb_hook &cmsb_hookp &cmsb_varr
	&cmsb_classes &cmsb_modules
	&cmsb_url &cmsb_url2classid &cmsb_classOK &cmsb_class_guess
	&cmsb_regpm &cmsb_modload
	$user $group
	&cmsb_event_call &cmsb_event_reg &cmsb_event_unreg &cmsb_event_ro
	
	&cmsb_rpc &cmsb_rpca
);

our @EXPORT_OK = qw
(
	&make_cached_connection
	%dbh_pull %object_events
);

use Encode ();
use Carp ();

#use CGI::Minimal;

our $VERSION = 3.0.0.0;
our $version = '3.0.0.0';


require CMSBuilder::Module;
require CMSBuilder::Object;
#require CMSBuilder::Property;
#require CMSBuilder::DB;
#require CMSBuilder::DBDefault;

use CMSBuilder::Config '$cfg';
use CMSBuilder::Config::XML;

use CMSBuilder::Utils;
#use CMSBuilder::IO;

our
(
	@modules,@classes,
	%object_events,
	%dbh_pull,
	$cmsb_error
);

#——————————————————————————— Экпортируемые функции —————————————————————————————

sub make_cached_connection
{
	my $db_name = shift;
	
	Carp::croak("Tryin to make_cached_connection() for exists connection: '$db_name'") if exists $dbh_pull{$db_name};
	
	$dbh_pull{$db_name} = $cfg->{db}->{connections}->{$db_name}->{'class'}->connect($cfg->{db}->{connections}->{$db_name})
		or Carp::croak("Can`t make_cached_connection() for: '$db_name'");
}

sub cmsb_rpca
{
	my $opts = shift;
	my $pkg = caller;
	
	map { cmsb_rpc($pkg,$_,$opts) } @_;
}

sub cmsb_rpc($$;$)
{
	no strict 'refs';
	
	my $pkg = @_ == 3 ? shift : caller;
	my $func = shift;
	my $opts = shift;
	
	Carp::carp("cmsb_rpc: function '$func' is not defined in package '$pkg' ISA = (@{$pkg . '::ISA'})") if $^W && !$pkg->can($func);
	
	*{$pkg . '::_cmsb_rpc_' . $func} = sub {$opts};
}

sub cmsb_hook($$)
{
	no strict 'refs';
	
	my ($sub,$ref) = @_;
	
	my $old = *{$sub}{'CODE'};
	
	Carp::croak "Not CODEref passed to cmsb_hook() as second arg: $ref" unless ref $ref eq 'CODE';
	Carp::croak "Not existed function name passed to cmsb_hook() as first arg: $sub" unless ref $old eq 'CODE';
	*{$sub} = sub {$ref->($old,@_)};
}

sub cmsb_hookp($$)
{
	no strict 'refs';
	
	my ($old,$new) = @_;
	Carp::croak "Value of first arg id not a package name in cmsb_hookp(): $old" unless defined %{$old.'::'};
	Carp::croak "Value of second arg id not a package name in cmsb_hookp(): $new" unless defined %{$new.'::'};
	
	my $i;
	++$i while defined %{$old.$i.'::'};
	
	%{$old.$i.'::'} = %{$old.'::'};
	%{$old.'::'} = %{$new.'::'};
	push @{$old.'::ISA'}, $old.$i;
	
	return $old.$i;
}

sub cmsb_varr($$;$)
{
	my $d = (!defined $_[2] && 1) || $_[2];
	
	_cmsb_varr($_[0], $_[1], $d, 0);
}

sub _cmsb_varr($$$$);
sub _cmsb_varr($$$$)
{
	no strict 'refs';
	
	my $c = shift;
	my $var = shift;
	my $d = shift;
	my $n = shift;
	
	return if $n > 50;
	
	my @sv;
	my @tv;
	
	@tv = &{$c . '::' . $var} if *{$c . '::' . $var}{'CODE'};
	
	if ($d)
	{
		push @sv, @tv;
		
		for my $pc (@{$c . '::ISA'})
		{
			push @sv, _cmsb_varr($pc, $var, $d, $n + 1);
		}
	}
	else
	{
		for my $pc (reverse @{$c . '::ISA'})
		{
			push @sv, _cmsb_varr($pc, $var, $d, $n + 1);
		}
		
		push @sv, @tv;
	}
	
	return @sv;
}

sub cmsb_event_ro
{
	return bless {}, 'CMSBuilder::Object';
}

sub cmsb_event_reg
{
	my $type = shift;
	my $sub = shift;
	my $class = shift || 'CMSBuilder::Object';
	
	Carp::croak "empty type passed to cmsb_event_reg()" unless $type;
	Carp::croak "empty sub passed to cmsb_event_reg()" unless $sub;
	
	Carp::croak "not subname passed to cmsb_event_reg(): $sub" if !ref($sub) && !$class->can($sub);
	Carp::croak "not CODEref passed to cmsb_event_reg(): $sub" if ref($sub) && ref($sub) ne 'CODE';
	
	push @{$object_events{$type}}, {class => $class, sub => $sub};
	
	return $#{$object_events{$type}};
}

sub cmsb_event_unreg
{
	my $type = shift;
	my $sub = shift;
	my $class = shift || 'CMSBuilder::Object';
	
	Carp::croak "empty type passed to cmsb_event_unreg()" unless $type;
	Carp::croak "empty sub passed to cmsb_event_unreg()" unless $sub;
	
	Carp::croak "not subname passed to cmsb_event_unreg(): $sub" if !ref($sub) && !$class->can($sub);
	Carp::croak "not CODEref passed to cmsb_event_unreg(): $sub" if ref($sub) && ref($sub) ne 'CODE';
	
	my $olen = $#{$object_events{$type}};
	
	@{$object_events{$type}} = grep { ($_->{'sub'} ne $sub) || ($_->{'class'} ne $class) } @{$object_events{$type}};
	
	return $olen != $#{$object_events{$type}};
}

sub cmsb_event_call
{
	my $obj = shift;
	my $type = shift;
	Carp::croak "empty type passed to cmsb_event_call()" unless $type;
	
	local $obj->{'__event_call_cancel'} = 0;
	
	my(@res,$sb);
	for my $code (@{$object_events{$type}})
	{
		next unless $obj->isa($code->{'class'});
		$sb = $code->{'sub'};
		push @res, $obj->$sb(@_);
		last if $obj->{'__event_call_cancel'};
	}
	
	return unless @res;
	return @res;
}

sub cmsb_modload
{
	my $mod = shift;
	my $pls = $CMSBuilder::Config::path_modules;
	
	warn "cmsb_modload('$mod')" if $^W;
	
	return unless -d $pls . '/' . $mod;
	
	my @files = listfiles($pls . '/' . $mod, 'pm', 'pl');
	
	my $ofn = $pls . '/' . $mod . '/.cmsb_load_order';
	@files = integrate_arrays([split /\s+/s, f2var($ofn)],\@files) if -f $ofn;
	
	for my $f (@files)
	{
		require 'CBM/' . $mod . '/' . $f;
		cmsb_regpm('CBM::' . $mod . '::' . $f) if $f =~ s/\.pm$//;
	}
	
	return 1;
}

sub cmsb_regpm
{
	my $cnt = 0;
	my @non;
	for my $pm (@_)
	{
		my $f;
		if($pm->isa('CMSBuilder::Module'))
		{
			@modules = grep { $_ ne $pm || do { warn "redefine module '$_'"; 0} } @modules;
			push @modules, $pm;
			$f = 1;
		}
		
		if($pm->isa('CMSBuilder::Object'))
		{
			@classes = grep { $_ ne $pm || (warn "redefine class '$_'")  && 0 } @classes;
			push @classes, $pm;
			$f = 1;
		}
		
		$f ? $cnt++ : push @non, $pm;
	}
	
	if(scalar @_ == $cnt)
	{
		return 1;
	}
	else
	{
		$cmsb_error = 'Non cmsb_regpm()`ed pms: ' . join(', ',@non);
		warn $cmsb_error if $^W >= 2;
		return;
	}
}

sub cmsb_modules() { return @modules; }
sub cmsb_classes() { return @classes; }

sub cmsb_url
{
	my $url = shift;
	
	my ($class,$id) = cmsb_url2classid($url);
	#warn "$url -> $class,$id";
	$class = cmsb_class_guess($class);
	
	#warn cmsb_classes();
	
	return unless $class;
	return unless cmsb_classOK($class);
	
	return $class->load($id);
}

sub cmsb_url2classid
{
	return $_[0] ? $_[0] =~ m/^([A-Za-z\_\:]+)(\d+)?$/ : ();
}

sub cmsb_classOK
{
	if(indexA([cmsb_classes()],$_[0]) >= 0){ return 1; }
	return 0;
}

sub cmsb_class_guess
{
	my @cns = grep { lc($_[0]) eq lc($_) } cmsb_classes();
	return @cns==1?$cns[0]:();
}

#—————————————————————————————— Интерфейсные функции ———————————————————————————

sub load
{
	warn '== CMSBuilder::load ==' if $^W;
	@modules = @classes = %object_events = ();
	
	map { cmsb_modload($_) } integrate_arrays($cfg->{etc}->{modules}->{load_order}, [ listdirs($cfg->{path}->{modules}) ]);
	
	map { $_->mod_load } integrate_arrays($cfg->{etc}->{modules}->{load_order}, \@modules);
}

sub configure
{
	# главный конфиг
	require 'config.xml';
	
	for my $mod (@modules){ $mod->mod_configure; }
}

sub init
{
	warn '== CMSBuilder::init ==' if $^W;
	CMSBuilder::IO->start();
	for my $mod (@modules){ $mod->mod_init; }
}

sub check_redirect
{
	err500('REDIRECT_STATUS ne "' . $cfg->{cgi}->{redirect_status} . '"')
		if $cfg->{cgi}->{redirect_status} && $ENV{'REDIRECT_STATUS'} ne $cfg->{cgi}->{redirect_status};
}

sub process
{
	warn '== CMSBuilder::process ==' if $^W;
	check_redirect();
	
	#my $cgi = CGI::Minimal->new;
	
	#CGI::param('a');
	my $r = {};#decode_utf8_hashref{CGI->Vars()};
	
	$r->{'_cmsb'} =
	{
		path => $ENV{'PATH_INFO'},
		redirect_status => $ENV{'REDIRECT_STATUS'},
	};
	
	for my $cn (@{$cfg->{server}->{process_classes}})
	{
		return if $cn->process_request($r)
	}
	
	#err404
	warn('File not found: "'.$ENV{'PATH_TRANSLATED'}.'" by "'.$ENV{'PATH_INFO'}.'"');
}

sub destruct
{
	warn '== CMSBuilder::destruct ==' if $^W;
	for my $mod (reverse @modules){ $mod->mod_destruct }
	CMSBuilder::IO->stop;
}

sub unload
{
	warn '== CMSBuilder::unload ==' if $^W;
	for my $mod (reverse @modules){ $mod->mod_unload }
}

1;