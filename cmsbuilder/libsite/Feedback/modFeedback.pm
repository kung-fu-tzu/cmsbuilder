
#-------------------------------------------------------------------------------
# ���� modFeedback.pm � cmsbuilder/libsite
# �������� ����
#-------------------------------------------------------------------------------

package modFeedback;
use strict qw(subs vars);
our $VERSION = 1.0.0.1;

our @ISA = ('plgnSite::Member','CMSBuilder::DBI::TreeModule');
sub _cname {'������-�����'}
sub _add_classes {qw/!* fbTheme/}
sub _aview {qw/name onpage emailme/}

sub _have_icon {1}

sub _props
{
	'name'		=> { 'type' => 'string', 'length' => 50, 'name' => '��������' },
	'emailme'	=> { 'type' => 'checkbox', 'name' => '���������� � ����� �������� �� e-mail' }
}

#-------------------------------------------------------------------------------


use CMSBuilder::Utils;

sub install_code
{
	my $o = shift;
	
	my $root_module = modRoot->new(1);
	
	my $this_module = $o->cre();
	$this_module->{'name'} = '������ - �����';
	$this_module->{'refresh'} = 5;
	$this_module->{'messagesonpage'} = 15;
	$this_module->{'themesonpage'} = 30;
	$this_module->save();		
	
	$root_module->elem_paste($this_module);
}

#-------------------------------------------------------------------------------
sub mod_is_installed {1}
#-------------------------------------------------------------------------------
#������������� ������ ���. ���� �� ������� �����, ���� �� ��������.
sub site_content
{
	my $o = shift;
	my $r = shift;
	
	print '<div class="mod-feedback">';
	
	if(!$o->len())
	{
		print '<div class="message">������������� �� ������ �� ����� ����, �� ������� ����� ������ ������.</div>';
	}
	elsif($o->len() == 1) #���� ����. Ÿ ����� ��� � �������.
	{
		($o->get_all())[0]->site_content($r,@_);
	}
	else
	{
		map { $_->site_preview() } $o->get_page($r->{'page'});
	}
	
	print '</div>';
}
#-------------------------------------------------------------------------------

1;