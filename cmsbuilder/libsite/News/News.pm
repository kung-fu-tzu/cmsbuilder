# (с) Леонов П.А., 2005

package News;
use strict qw(subs vars);
use utf8;

our @ISA = ('modSite::Object','CMSBuilder::DBI::Object');

sub _cname {'Новость'}
sub _aview {qw/name content ndate/}
sub _have_icon {1}

sub _props
{
	'name'		=> { 'type' => 'string', 'length' => 100, 'name' => 'Заголовок' },
	'content'	=> { 'type' => 'miniword', 'name' => 'Текст' },
	'ndate'		=> { 'type' => 'date', 'name' => 'Дата' }
}

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder::Utils;

sub site_content
{
	my $o = shift;
	
	print $o->{'content'};
}

sub site_preview
{
	my $o = shift;
	
	print
	'
		<div class="news">
			<div class="head">',$o->name(),'</div>
			<div class="date">',toDateStr($o->{'ndate'}),'</div>
			<div class="body">',$o->preview_text(),'</div>
			<div class="more"><a href="',$o->site_href(),'">Подробнее...</a></div>
		</div>
	';
}

sub preview_text
{
	my $o = shift;
	
	my $desc = $o->{'content'};
	$desc =~ s/<.*?>/ /sg;
	$desc =~ s/&nbsp;?/ /g;
	$desc =~ s/^\s+|\s+$//g;
	
	my @words = split /\s+/, $desc;
	
	$desc = join ' ',@words[0..9];
	$desc =~ s/([\.\?\!]+$)|([\,\;\:\-]+$)//;
	
	return $desc.(@words>10 && !$1?'...':'');
}

1;