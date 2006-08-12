# (с) Леонов П. А., 2005-2006

package CMSBuilder;
use strict qw(subs vars);
require 5.8.2;
use utf8;

use Exporter;
our @ISA = 'Exporter';
our @EXPORT =
qw(
&cmsb_hook &cmsb_hookp &cmsb_varr
&cmsb_classes &cmsb_modules
&cmsb_url &cmsb_url2classid &cmsb_classOK &cmsb_class_guess
&cmsb_regpm &cmsb_modload
$user $group
&cmsb_event_reg &cmsb_event_unreg &cmsb_event_ro
);

use Encode ();
use Carp;

our $VERSION = 3.0.0.0;
our $version = '3.0.0.0';

require CMSBuilder::Property;
require CMSBuilder::Utils;
require CMSBuilder::EML;
require CMSBuilder::MYURL;
require CMSBuilder::IO;
require CMSBuilder::DBI;
require CMSBuilder::Module;


use CMSBuilder::Utils;
use CMSBuilder::IO;

our
(
	@modules,@classes,
	%dbo_cache,%oevents
);

#——————————————————————————— Экпортируемые функции —————————————————————————————

sub cmsb_hook($$)
{
	my ($sub,$ref) = @_;
	croak "Not CODEref passed to cmsb_hook() as second arg: $ref" unless ref $ref eq 'CODE';
	
	my $old = *{$sub}{'CODE'};
	*{$sub} = sub {&$ref($old,@_)};
}

sub cmsb_hookp($$)
{
	my ($old,$new) = @_;
	croak "Value of \$old id not a package name in cmsb_hookp(): $old" unless defined %{$old.'::'};
	croak "Value of \$new id not a package name in cmsb_hookp(): $new" unless defined %{$new.'::'};
	
	my $i;
	++$i while defined %{$old.$i.'::'};
	
	%{$old.$i.'::'} = %{$old.'::'};
	%{$old.'::'} = %{$new.'::'};
	push @{$old.'::ISA'}, $old.$i;
	
	return $old.$i;
}

sub cmsb_varr($$@)
{
	my $c = shift;
	my $var = shift;
	my $d = shift;
	my @sv;
	
	for my $pc (reverse @{$c.'::ISA'})
	{
		push(@sv,cmsb_varr($pc,$var,$d));
	}
	
	if(*{$c.'::'.$var}{'CODE'}){ $d?(unshift(@sv,&{$c.'::'.$var})):(push(@sv,&{$c.'::'.$var})); }
	
	return @sv;
}

sub cmsb_event_ro
{
	return bless {}, 'CMSBuilder::DBI::EventsInterface';
}

sub cmsb_event_reg
{
	my $type = shift;
	my $sub = shift;
	my $class = shift || 'UNIVERSAL';
	
	push @{$oevents{$type}}, {'class' => $class, 'sub' => $sub};
	
	return $#{$oevents{$type}};
}

sub cmsb_event_unreg
{
	my $type = shift;
	my $sub = shift;
	my $class = shift || 'CMSBuilder::DBI::Object';
	
	my $olen = $#{$oevents{$type}};
	
	@{$oevents{$type}} = grep { $_->{'sub'} ne $sub && $_->{'class'} ne $class } @{$oevents{$type}};
	
	return $olen != $#{$oevents{$type}};
}

sub cmsb_modload
{
	my $mod = shift;
	my $pls = $CMSBuilder::Config::path_modules;
	
	return unless -d $pls . '/' . $mod;
	
	my @pms = listfiles($pls . '/' . $mod,'pm');
	my @pls = listfiles($pls . '/' . $mod,'pl');
	
	for my $pm (@pms)
	{
		require $pls . '/' . $mod . '/' . $pm . '.pm';
		cmsb_regpm($mod . '::' . $pm);
	}
	
	for my $pl (@pls)
	{
		require $pls . '/' . $mod . '/' . $pl . '.pl';
	}
	
	return 1;
}

sub cmsb_regpm
{
	for my $pm (@_)
	{
		if($pm->isa('CMSBuilder::Module'))
		{
			@modules = grep { $_ ne $pm || (warn "redefine module '$_'") && 0 } @modules;
			push @modules, $pm;
		}
		
		if($pm->isa('CMSBuilder::DBI::Object'))
		{
			@classes = grep { $_ ne $pm || (warn "redefine class '$_'")  && 0 } @classes;
			push @classes, $pm;
		}
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
	
	return unless cmsb_classOK($class);
	return unless $class && $id;
	return unless my $to = $class->new($id);
	return unless $to->id;
	
	return $to;
}

sub cmsb_url2classid
{
	my $url = shift;
	return $url =~ m/^([A-Za-z\_\:]+)(\d+)$/;
}

sub cmsb_classOK
{
	if(indexA($_[0],cmsb_classes()) >= 0){ return 1; }
	return 0;
}

sub cmsb_class_guess
{
	my @cns = grep { lc($_[0]) eq lc($_) } cmsb_classes();
	return @cns==1?$cns[0]:();
}

#———————————————————————————————— Базовые функции ——————————————————————————————

sub ocache_save()
{
	for my $to (values(%dbo_cache)){ $to->save(); }
}

sub ocache_clear()
{
	if($CMSBuilder::Config::autosave)
	{
		ocache_save();
	}
	
	%dbo_cache = ();
}

#—————————————————————————————— Интерфейсные функции ———————————————————————————

sub load
{
	@modules = @classes = ();
	%oevents = ();
	
	cmsb_regpm('CMSBuilder::DBI'); # обязательно раньше всех
	
	map { cmsb_modload($_) } listdirs($CMSBuilder::Config::path_modules);
	
	for my $mod (@modules){ $mod->mod_load(); }
}

sub init
{
	CMSBuilder::Config::init();
	
	ocache_clear();
	CMSBuilder::IO->start();
	for my $mod (@modules){ $mod->mod_init(); }
}

sub process
{
	err500('REDIRECT_STATUS ne "'.$CMSBuilder::Config::redirect_status.'"') if $CMSBuilder::Config::redirect_status && $ENV{'REDIRECT_STATUS'} ne $CMSBuilder::Config::redirect_status;
	
	CGI::param('a');
	my $r = decode_utf8_hashref{CGI->Vars()};
	
	$r->{'_cmsb'} =
	{
		'path' => $ENV{'PATH_INFO'},
		'redirect_status' => $ENV{'REDIRECT_STATUS'},
	};
	
	# для mod_perl
	delete $ENV{'REDIRECT_STATUS'};
	
	for my $cn (@CMSBuilder::Config::process_classes)
	{
		return if $cn->process_request($r)
	}
	
	
	err404('File not found: "'.$ENV{'PATH_TRANSLATED'}.'" by "'.$ENV{'PATH_INFO'}.'"');
}

sub destruct
{
	for my $mod (reverse @modules){ $mod->mod_destruct(); }
	CMSBuilder::IO->stop();
	ocache_clear();
}

sub unload
{
	for my $mod (reverse @modules){ $mod->mod_unload(); }
}

1;