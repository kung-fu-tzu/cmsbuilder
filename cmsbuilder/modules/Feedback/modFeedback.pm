# CMSBuilder::Feedback © Токмаков А. И.

package modFeedback;
use strict qw(subs vars);
use utf8;

our $VERSION = 1.0.0.1;

our @ISA = qw(modSite::Member modAdmin::Tree CMSBuilder::DBI::Array CMSBuilder::Module);
sub _cname {'Вопрос-ответ'}
sub _add_classes {qw(!* fbTheme)}
sub _aview {qw(name onpage emailme)}

sub _have_icon {1}

sub _props
{
	name		=> { type => 'string', length => 50, name => 'Название' },
	emailme		=> { type => 'checkbox', name => 'Уведомлять о новых вопросах по e-mail' }
}

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder::Utils;

sub install_code
{
	my $o = shift;
	
	my $root_module = modAdmin::modAdmin->root;
	
	my $this_module = $o->cre();
	$this_module->{'name'} = 'Вопрос - ответ';
	$this_module->{'refresh'} = 5;
	$this_module->{'messagesonpage'} = 15;
	$this_module->{'themesonpage'} = 30;
	$this_module->save();		
	
	$root_module->elem_paste($this_module);
}

sub mod_is_installed {1}

#Распечатывает список тем. Если их слишком много, бьёт на страницы.
sub site_content
{
	my $o = shift;
	my $r = shift;
	
	print '<div class="mod-feedback">';
	
	if(!$o->len())
	{
		print '<div class="message">Администратор не создал ни одной темы, по которой можно задать вопрос.</div>';
	}
	elsif($o->len() == 1) #Одна тема. Её прямо тут и выведем.
	{
		($o->get_all())[0]->site_content($r,@_);
	}
	else
	{
		map { $_->site_preview() } $o->get_page($r->{'page'});
	}
	
	print '</div>';
}


1;