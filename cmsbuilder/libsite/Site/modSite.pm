# (с) Леонов П.А., 2006

package modSite;
use strict qw(subs vars);
use utf8;

our @ISA = ('plgnSite::Member','CMSBuilder::DBI::TreeModule');

our $VERSION = 1.0.0.0;

sub _cname {'Сайт'}
sub _aview {qw/name bigname title_index title email address content/}
sub _have_icon {1}
sub _template_export {qw/mainmenu onmain onpage/}
sub _props
{
	'bigname'		=> { 'type' => 'string', 'name' => 'Название проекта' },
	'title_index'	=> { 'type' => 'string', 'name' => 'Заголовок на главной' },
	'title'			=> { 'type' => 'string', 'name' => 'Постоянная часть заголовка' },
	'email'			=> { 'type' => 'string', 'length' => 50, 'name' => 'E-mail администратора' },
	'address'		=> { 'type' => 'string', 'length' => 50, 'name' => 'Адрес сайта' },
	'content'		=> { 'type' => 'miniword', 'name' => 'Текст' },
}

#———————————————————————————————————————————————————————————————————————————————


sub onpage
{
	my $c = shift;
	my $obj = shift;
	my $r = shift;
	my $h = shift;
	
	if($r->{'eml'}->{'uri'} ne '/')
	{
		print $h;
	}
}

sub onmain
{
	my $c = shift;
	my $obj = shift;
	my $r = shift;
	my $h = shift;
	
	if($r->{'eml'}->{'uri'} eq '/')
	{
		print $h;
	}
}

sub install_code
{
	my $mod = shift;
	
	my $mr = modRoot->new(1);
	
	my $to = $mod->cre();
	$to->{'name'} = 'Главная';
	$to->{'address'} = 'http://'.$ENV{'SERVER_NAME'}.'/';
	$to->{'email'} = 'info@'.join('.',grep {$_} reverse ((reverse split /\./, $ENV{'SERVER_NAME'})[0,1]));
	$to->save();
	
	$mr->elem_paste($to);
}

sub site_title
{
	my $o = shift;
	
	return $o->SUPER::site_title(@_) unless $o->{'title_index'};
	print $o->{'title_index'};
}

sub site_href
{
	return '/';
}

1;