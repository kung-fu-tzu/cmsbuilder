# CMSBuilder © Леонов П. А., 2006

package modCatalog::Dir;
use strict qw(subs vars);
use utf8;

our @ISA = ('modCatalog::Member','CMSBuilder::DBI::Array');

sub _cname {'Раздел'}
sub _aview {qw/name photo desc onpage previewtype/}
sub _have_icon {1}

sub _props
{
	'previewtype'	=> { 'type' => 'select', 'variants' => [{'text'=>'текст'},{'list'=>'список подразделов'}], 'name' => 'Краткое описание' },
}

#———————————————————————————————————————————————————————————————————————————————

sub catalog_preview_text
{
	my $o = shift;
	
	if($o->{'previewtype'} eq 'list')
	{
		return join('', map { $_->site_aname() } $o->get_page(0));
	}
	else
	{
		return $o->SUPER::catalog_preview_text(@_);
	}
}



1;