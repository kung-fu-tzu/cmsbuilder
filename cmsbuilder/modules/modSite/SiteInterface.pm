# CMSBuilder © Леонов П. А., 2005-2006

package modSite::Interface;
use strict qw(subs vars);
use utf8;

our @ISA = 'modTemplates::Interface';

sub _template_export
{qw/
site_submenu site_mainmenu site_navigation site_content site_contentbox site_flatlist
site_title site_description site_script
site_preview site_mainpreview site_href site_head site_aname site_pagesline
site_cdate site_adate
/}
sub _sview { return shift()->aview(@_) }

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder;
use CMSBuilder::Utils;
use CMSBuilder::IO;

sub sview { return shift()->_sview(@_) }

sub site_props
{
	my $o = shift;
	my $na =
	{
		-keys => [$o->sview()],
		@_
	};
	
	my $p = $o->props();
	
	return unless @{$na->{-keys}};
	
	my $vt;
	for my $key (@{$na->{-keys}})
	{
		do { warn ref($o).': _props{} has no key "'.$key.'"'; next } unless exists $p->{$key};
		$vt = 'CMSBuilder::DBI::vtypes::'.$p->{$key}{'type'};
		
		print '<div class="',$key,'">',$vt->sview( $key, $o->{$key}, $o ),'</div>';
	}
	
	return 1;
}

sub site_cdate
{
	my $o = shift;
	my $r = shift;
	
	return toDateStr($o->{'CTS'});
}

sub site_adate
{
	my $o = shift;
	my $r = shift;
	
	return toDateStr($o->{'ATS'});
}

sub site_flatlist
{
	my $o = shift;
	my $r = shift;
	
	my $mobj = $r->{'main_obj'};
	
	print '<ul>';
	
	for my $to ($o->get_all())
	{
		next if $to->{'hidden'};
		print '<li class="'.($mobj->isapapa($to)?'selected':'item').'">'.($mobj->myurl() eq $to->myurl()?('<span>'.$to->site_name().'</span>'):$to->site_aname()).'</li>';
	}
	
	print '</ul>';
}

sub site_pagesline
{
	my $o = shift;
	my $r = shift;
	
	return unless $o->can('pages');
	
	if($o->pages() < 2){ return; }
	
	print '<div class="pagesline"><span class="text">Страницы:</span>';
	
	for my $p (0 .. $o->pages()-1)
	{
		if($p == $r->{'page'})
		{
			print '<span class="current">'.($p+1).'</span>';
		}
		else
		{
			print '<span class="other"><a href="'.$o->site_href().'?page='.$p.'">'.($p+1).'</a></span>';
		}
	}
	print '</div>';
}

sub site_submenu
{
	my $o = shift;
	my $r = shift;
	
	return unless $o->len();
	
	print '<div class="submenu">';
	
	for my $to ($o->get_all())
	{
		print '<div class="subpage">',$to->site_aname(),'</div>';
	}
	
	print '</div>';
}

sub site_template
{
	my $o = shift;
	my $r = shift;
	
	my $tpl = $o->{'template'} || ($o->papa()?$o->papa()->site_template($r):undef);
	
	return $tpl;
}

sub site_page
{
	my $o = shift;
	my $r = shift;
	
	my $tpl = $o->site_template() || cmsb_url('modTemplates::Template1');
	
	#if($o->{'hidden'}){ return err404("Hidden element"); }
	unless($tpl){ return err404("No template for viewving $o"); }
	
	print $tpl->parse($o,$r);
}

sub site_navigation
{
	my $o = shift;
	
	my @all;
	my $cnt = 0;
	
	unshift(@all,$o->name());
	
	while($o = $o->papa() and $cnt++ < 50)
	{
		unshift(@all, $o->site_aname());
	}
	
	#shift @all;
	
	print join('&nbsp;&gt; ',@all);
}

sub site_content
{
	my $o = shift;
	
	print $o->{'content'};
}

sub site_title
{
	my $o = shift;
	
	if($o->{'title'}){ print $o->{'title'}; return; }
	
	my $ttl = $o->site_name();
	my $gttl = $o->papaN(0)->{'title'};
	
	print $gttl?"$ttl — $gttl":$ttl;
}

sub site_description
{
	my $o = shift;
	my $r = shift;
	
	$o->{'description'}?(print $o->{'description'}):($o->papa()?$o->papa()->site_description($r):'');
}

sub site_script
{
	my $o = shift;
	my $r = shift;
}

sub site_preview
{
	my $o = shift;
	
	print '<h4>',$o->{'name'},'</h4><p>Предварительный вывод (site_preview) для класса "',ref($o),'" не определён.</p>';
}

sub site_mainpreview
{
	my $o = shift;
	
	print '<h4>',$o->{'name'},'</h4><p>Вывод на главной (site_index) для класса "',ref($o),'" не определён.</p>';
}

sub site_href
{
	my $o = shift;
	my $page = shift;
	
	return '/'.lc($o->myurl()).'.html';
}

sub site_abshref
{
	my $o = shift;
	my $page = shift;
	
	my $base = $o->root->{'address'};
	chop $base;
	
	return $base.$o->site_href();
}

sub site_name
{
	my $o = shift;
	
	my $name = $o->name();
	$name =~ s/\s+/ /g;
	$name =~ s/<.*?>//g;
	
	return $name;
}

sub site_head
{
	my $o = shift;
	
	print $o->site_name();
}

sub site_aname
{
	my $o = shift;
	
	return '<a href="'.$o->site_href().'">'.$o->name().'</a>';
}

1;