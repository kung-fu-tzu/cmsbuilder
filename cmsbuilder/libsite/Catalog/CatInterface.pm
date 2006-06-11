# (с) Леонов П.А., 2005

package plgnCatalog::Interface;
use strict qw(subs vars);
our @ISA = 'plgnSite::Interface';

#-------------------------------------------------------------------------------


sub catalog_props
{
	my $o = shift;
	
	return '<div class="props">'.join('',map { '<div class="'.$_.'">'.$o->{$_}.'</div>' } $o->aview()).'</div>';
}

sub catalog_preview_text
{
	my $o = shift;
	
	$o->{'desc'} =~ m#<p>(.+?)</p>#;
	
	my $desc = $1 || $o->{'desc'};
	$desc =~ s/<.*?>/ /sg;
	$desc =~ s/&nbsp;?/ /g;
	$desc =~ s/^\s+|\s+$//g;
	
	my @words = split /\s+/, $desc;
	
	$desc = join ' ',@words[0..9];
	$desc =~ s/([\.\?\!]+$)|([\,\;\:\-]+$)//;
	
	return $desc.(@words>10 && !$1?'...':'').$1;
}

sub site_preview
{
	my $o = shift;
	
	my $img;
	
	if($o->{'img'} && $o->{'img'}->exists()){ $img = '<div class="photo" style="background:url('.$o->{'img'}->href().')"><img class="nullpls" src="/img/null.gif" alt="'.$o->name().'" /></div>' }
	
	print
	'
		<div class="preview">
			',$img,$o->catalog_props(),'
			<div class="desc">
				<div class="name">',$o->name(),'</div>
				<div class="text">',$o->catalog_preview_text(@_),'</div>
			</div>
			<div class="more"><a href="',$o->site_href(),'">Подробнее...</a></div>
		</div>
	';
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
		print '<hr>';
		map { $_->site_preview() } $o->get_all();
	}
	else
	{
		print '<div class="empty">Пусто</div>';
	}
	
	$o->site_pagesline(@_);
	
	print '<hr>' if $o->{'desc'} && $o->len();
	print $o->{'desc'} if $o->{'desc'};
	
	print '</div>';
}


1;