# (с) Леонов П.А., 2005

package CMSBuilder;
use Exporter;
use strict qw(subs vars);
our @ISA = 'Exporter';
our @EXPORT =
qw/
&cmsb_allclasses &cmsb_url &cmsb_url2classid &cmsb_classOK &cmsb_class_guess &cmsb_allclasses
&cmsb_regpm &cmsb_pathload &cmsb_coreload &cmsb_siteload
$user $group
&cmsb_event_reg &cmsb_event_unreg &cmsb_event_ro
/;

our $VERSION = 2.12.82.110;
our $version = '2.12.82-110';

require CMSBuilder::Property;
require CMSBuilder::Utils;
require CMSBuilder::EML;
require CMSBuilder::IO;
require CMSBuilder::DBI;
require CMSBuilder::Plugin;


use CMSBuilder::Utils;

our
(
	@plugins,@classes,@modules,
	
	$user,$group,
	
	%dbo_cache,
	
	%oevents
);


################################################################################
# Экпортируемые функции
################################################################################

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

sub cmsb_siteload
{
	my $dir = shift;
	
	return cmsb_pathload($CMSBuilder::Config::path_libsite.($dir?'/'.$dir:''),@_);
}

sub cmsb_coreload
{
	my $dir = shift;
	
	return cmsb_pathload($CMSBuilder::Config::path_libcore.($dir?'/'.$dir:''),@_);
}

sub cmsb_pathload
{
	my $dir = shift;
	
	# Инклудим пакеты
	my @pms = listpms($dir);
	for my $pm (@pms)
	{
		require( $dir.'/'.$pm.'.pm' );
		cmsb_regpm($pm);
	}
	
	return @pms;
}

sub cmsb_regpm
{
	for my $pm (@_)
	{
		if( grep { $pm eq $_ } (@classes,@modules,@plugins) ){ return; }
		
		if($pm->isa('CMSBuilder::Plugin'))
		{
			push @plugins, $pm;
			# Сообщаем плагину о том, что он загружен
			$pm->plgn_load();
			#print STDERR "Plugin: $pm\n";
		}
		elsif($pm->isa('CMSBuilder::DBI::Module'))
		{
			push @modules, $pm;
		}
		elsif($pm->isa('CMSBuilder::DBI::Object'))
		{
			push @classes, $pm;
		}
		#else
		#{
		#	warn "Can`t reg '$pm'";
		#}
	}
}

sub cmsb_allclasses() { return (@classes,@modules); }

sub cmsb_url
{
	my $url = shift;
	
	my ($class,$id) = cmsb_url2classid($url);
	
	$class = cmsb_class_guess($class);
	
	return unless cmsb_classOK($class);
	return unless $class && $id;
	return unless my $to = $class->new($id);
	return unless $to->{'ID'};
	
	return $to;
}

sub cmsb_url2classid
{
	my $url = shift;
	my ($class,$id);# = ('','');
	
	if( $url !~ m/^([A-Za-z\_]+)(\d+)$/ ){ return; }
	
	$class = $1;
	$id = $2;
	
	$class =~ s/\_/\:\:/;
	
	return ($class,$id);
}

sub cmsb_classOK
{
	if(indexA($_[0],cmsb_allclasses()) >= 0){ return 1; }
	return 0;
}

sub cmsb_class_guess
{
	my @cns = grep { lc($_[0]) eq lc($_) } cmsb_allclasses();
	return @cns==1?$cns[0]:();
}

################################################################################
# Базовые функции
################################################################################

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


################################################################################
# Интерфейсные функции
################################################################################

sub load
{
	@plugins = @classes = @modules = ();
	%oevents = ();
	
	cmsb_regpm('CMSBuilder::DBI'); # обязательно раньше всех
	
	cmsb_coreload();
	cmsb_siteload();
}

sub init
{
	CMSBuilder::Config::init();
	
	ocache_clear();
	CMSBuilder::IO->start();
	for my $plg (@plugins){ $plg->plgn_init(); }
}

sub destruct
{
	for my $plg (reverse @plugins){ $plg->plgn_destruct(); }
	CMSBuilder::IO->stop();
	ocache_clear();
}

sub unload
{
	for my $plg (reverse @plugins){ $plg->plgn_unload(); }
}

1;