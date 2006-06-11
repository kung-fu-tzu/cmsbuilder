# (с) Леонов П.А., 2005

package plgnCatalog::Member;
use strict qw(subs vars);
our @ISA = ('plgnCatalog::Interface','plgnSite::Object');

sub _add_classes {qw/!* plgnCatalog::Member !modCatalog/}
sub _aview {qw/img desc/}

sub _props
{
	'img'		=> { 'type' => 'file', 'msize' => 100, 'ext' => [qw/bmp jpg gif txt html/], 'name' => 'Картинка' },
	'desc'		=> { 'type' => 'miniword', 'name' => 'Описание' },
}

#-------------------------------------------------------------------------------


1;