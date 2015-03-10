# (�) ������ �.�., 2005

package CatDir;
use strict qw(subs vars);
our @ISA = ('plgnCatalog::Member','CMSBuilder::DBI::Array');

sub _cname {'������'}
sub _aview {qw/name img desc onpage previewtype/}
sub _have_icon {1}

sub _props
{
	'previewtype'	=> { 'type' => 'select', 'variants' => [{'text'=>'�����'},{'list'=>'������ �����������'}], 'name' => '������� ��������' },
}

#-------------------------------------------------------------------------------

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