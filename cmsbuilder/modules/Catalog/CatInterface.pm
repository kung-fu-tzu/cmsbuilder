# CMSBuilder © Леонов П. А., 2006

package modCatalog::Interface;
use strict qw(subs vars);
use utf8;

#———————————————————————————————————————————————————————————————————————————————

sub catalog_props
{
	my $o = shift;
	my $r = shift;
	
	my $p = $o->props();
	my $vt = 'CMSBuilder::DBI::vtypes::';
	return '<div class="props">'.join('',map {'<div class="'.$_.'">'.$o->{$_}.'</div>'} keys %$p).'</div>',
}

sub catalog_preview_text
{
	my $o = shift;
	
	my $desc = $o->{'desc'} =~ m{<p>(.+?)</p>}s || $o->{'desc'};
	
	$desc =~ s/<.*?>/ /sg;
	$desc =~ s/&nbsp;?/ /g;
	$desc =~ s/^\s+|\s+$//g;
	
	my @words = split /\s+/, $desc;
	
	$desc = join ' ', @words[0..9];
	$desc =~ s/([\.\?\!]+$)|([\,\;\:\-]+$)/$1 || '…'/e || ($desc .= '…') if @words > 10;
	
	return $desc;
}

sub site_preview
{
	my $o = shift;
	
	my $photo_href;
	if($o->{'smallphoto'} && $o->{'smallphoto'}->exists)
	{
		$photo_href = $o->{'smallphoto'}->href
	}
	elsif((my $cr = $o->catalog_root)->{'shownophoto'})
	{
		$photo_href = $cr->{'nophotoimg'}->href();
	}
	my $photo = $photo_href ? '<a href="'.$o->site_href.'"><img class="photo" src="'.$photo_href.'"></a>' : undef;
	
	print
	'
		<div class="preview">
			',$photo,'
			<div class="desc">
				<div class="name">',$o->name,'</div>
				<div class="text">',$o->catalog_preview_text(@_),'</div>
			</div>
			<div class="more"><a href="',$o->site_href,'">Подробнее…</a></div>
		</div>
	';
}

sub catalog_root
{
	my $o = shift;
	
	map { return $_ if $_->isa('modCatalog') } reverse $o->papa_path;
	return;
}

sub catalog_navigation
{
	my $o = shift;
	
	my $prnt = $o->papaN(1);
	
	print
	'
	<div class="navigation">
		<div class="head">',$prnt->name(),'</div>
		<div class="content">
			',(map { $_->site_aname(); } $prnt->get_all()),'
		</div>
	</div>
	';
}

sub site_content
{
	my $o = shift;
	
	print '<div class="catalog">';
	
	if($o->len())
	{
		map { $_->site_preview() } $o->get_all();
	}
	else
	{
		print '<div class="message">Пусто</div>';
	}
	
	$o->site_pagesline(@_);
	
	print '<hr>' if $o->{'desc'} && $o->len();
	print $o->{'desc'};
	
	print '</div>';
}


1;