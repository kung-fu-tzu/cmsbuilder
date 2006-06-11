# (с) Леонов П.А., 2005

package CatWare;
use strict qw(subs vars);
our @ISA = ('plgnCatalog::Member','CMSBuilder::DBI::Object');

sub _cname {'Товар'}
sub _aview {qw/name img bigimg desc/}
sub _have_icon {1}

sub _props
{
	'bigimg'	=> { 'type' => 'file', 'msize' => 250, 'ext' => [qw/bmp jpg gif txt html/], 'name' => 'Большая картинка' },
}

#-------------------------------------------------------------------------------


sub site_content
{
	my $o = shift;
	
	my $img;
	my $zoom;
	
	print '<div class="catalog"><hr>';
	
	$o->catalog_navigation();
	
	if($o->{'img'}->exists()){ $img = '<img class="bigphoto" src="'.$o->{'img'}->href().'" alt="'.$o->name().'" />' }
	if($o->{'bigimg'}->exists()){ $img = '<img class="bigphoto" src="'.$o->{'bigimg'}->href().'" alt="'.$o->name().'" />' }
	
	print
	'
	<div class="ware">
		',$o->catalog_props(),$img,$o->{'desc'},'
		<div class="papa"><a href="',$o->papa()->site_href(),'">&larr;&nbsp;',$o->papa()->name(),'</a></div>
	</div>
	';
	
	print '<hr></div>';
}

1;