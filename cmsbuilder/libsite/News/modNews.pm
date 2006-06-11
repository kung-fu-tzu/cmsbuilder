# (с) Леонов П.А., 2005

package modNews;
use strict qw(subs vars);
our @ISA = ('plgnSite::Member','CMSBuilder::DBI::TreeModule');

sub _cname {'Новости'}
sub _add_classes {qw/!* News/}
sub _have_icon {1}
sub _pages_direction {0}
sub _aview{qw/name onpage/}

sub _props
{
	'name'	=> { 'type' => 'string', 'length' => 50, 'name' => 'Название' },
}

#-------------------------------------------------------------------------------


sub list
{
	my $o = shift;
	my $cnt = shift || 4;
	
	for my $to ($o->get_interval(1,$cnt))
	{
		$to->site_preview()
	}
	
	print '<a href="',$o->site_href(),'">Архив новостей</a>&nbsp;(',$o->len(),')';
}

sub site_content
{
	my $o = shift;
	my $r = shift;
	
	if($o->{'descr'})
	{
		print $o->{'descr'},'<br><br>';
	}
	
	print '<div class="newsblock">';
	
	for my $to ($o->get_page($r->{'page'}))
	{
		$to->site_preview();
		print '<br>';
	}
	
	print '</div>';
}

sub install_code {}
sub mod_is_installed {1}

1;