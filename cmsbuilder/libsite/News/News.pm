# (с) Леонов П.А., 2005

package News;
use strict qw(subs vars);
our @ISA = ('plgnSite::Object','CMSBuilder::DBI::Object');

sub _cname {'Новость'}
sub _aview {qw/name content ndate/}
sub _have_icon {1}

sub _props
{
	'name'		=> { 'type' => 'string', 'length' => 100, 'name' => 'Заголовок' },
	'content'	=> { 'type' => 'miniword', 'name' => 'Текст' },
	'ndate'		=> { 'type' => 'date', 'name' => 'Дата' }
}

#-------------------------------------------------------------------------------


use CMSBuilder::Utils;

sub site_page
{
	my $o = shift;
	print '<b>',$o->{'name'},'</b><br>';
	print $o->{'content'};
}

sub site_preview
{
	my $o = shift;
	
	print
	'
		<table class="news" width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr><td class="head">',$o->{'name'},'</td></tr>
			<tr><td class="body">',$o->{'content'},'</td></tr>
			<tr><td class="date">',toDateStr($o->{'ndate'}),'</td></tr>
			<tr height="18"><td>&nbsp;</td></tr>
		</table>
	';
}

1;