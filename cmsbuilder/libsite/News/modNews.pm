# (с) Леонов П.А., 2005

package modNews;
use strict qw(subs vars);
use utf8;

our @ISA = ('plgnSite::Member','CMSBuilder::DBI::TreeModule');

sub _cname {'Новости'}
sub _classes {qw/News/}
sub _add_classes {qw/!* News/}
sub _have_icon {1}
sub _pages_direction {0}
sub _aview{qw/name/}
sub _template_export {qw/newsline/}

sub _props
{
	'name'	=> { 'type' => 'string', 'length' => 50, 'name' => 'Название' },
}

#———————————————————————————————————————————————————————————————————————————————


sub newsline
{
	my ($c,$obj,$r,$h) = @_;
	
	$c->new(1)->list();
}

sub list
{
	my $o = shift;
	my $cnt = shift || 4;
	
	print '<div class="newsblock">';
	
	for my $to ($o->get_interval(1,$cnt))
	{
		$to->site_preview()
	}
	
	print '<div class="arch"><a href="',$o->site_href(),'">Архив новостей</a>(',$o->len(),')</div>';
	
	print '</div>';
}

sub site_content
{
	my $o = shift;
	
	if($o->{'descr'})
	{
		print $o->{'descr'},'<br><br>';
	}
	
	print '<div class="newsblock">';
	
	if($o->len())
	{
		for my $to ($o->get_all())
		{
			$to->site_preview();
			print '<br>';
		}
	}
	else
	{
		print 'Нет новостей.';
	}
	
	print '</div>';
}

sub install_code {}
sub mod_is_installed {1}

1;