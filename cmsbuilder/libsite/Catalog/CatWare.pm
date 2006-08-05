# (с) Леонов П.А., 2005

package modCatalog::Ware;
use strict qw(subs vars);
use utf8;

our @ISA = ('modCatalog::Member');

sub _aview {qw/price/}
sub _have_icon {'icons/CatWare.gif'}

sub _props
{
	'price'		=> { 'type' => 'int', 'name' => 'Цена' },
}

#———————————————————————————————————————————————————————————————————————————————

sub site_content
{
	my $o = shift;
	my $r = shift;
	
	my $photo;
	my $zoom;
	
	print '<div class="catalog">';
	
	$o->catalog_navigation();
	
	if($o->{'photo'}->exists()){ $photo = '<img class="photo" src="'.$o->{'photo'}->href().'" alt="'.$o->name().'" />' }
	
	print
	'
	<div class="ware">
		';
	
	$o->site_props($r);
	
	print
	$photo,$o->{'desc'},'
		<div class="papa"><a href="',$o->papa()->site_href(),'">',$o->papa()->name(),'</a></div>
	</div>
	';
	
	print '</div>';
}

1;