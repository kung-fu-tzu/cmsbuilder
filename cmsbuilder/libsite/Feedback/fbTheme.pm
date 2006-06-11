# (с) Токмаков А. И., 2005-2006

package fbTheme;
use strict qw(subs vars);
our @ISA = ('plgnSite::Object','CMSBuilder::DBI::FilteredArray','CMSBuilder::DBI::Array');

sub _cname {'Тема'}
sub _aview {'name','desc','onpage'}
sub _add_classes {qw/fbQuestion/}
sub _have_icon {1}

sub _props
{
	'name'	=> { 'type' => 'string', 'length' => 100, 'name' => 'Название' },
	'desc'	=> { 'type' => 'miniword', 'name' => 'Описание' }
}

#-------------------------------------------------------------------------------

use plgnUsers;
use CMSBuilder::Utils;

sub interval_filter
{
	my $o = shift;
	
	return @_ if !$o->papa() || $o->papa()->access('w');
	
	return grep {$_->{'answer'}} @_;
}

sub _have_icon 
{
	my $o = shift;
	
	return (grep {!$_->{'answer'}} $o->get_all())?'icons/fbTheme_new.gif':'icons/fbTheme.gif';
}

#-------------------------------------------------------------------------------
sub process_params
{
	my $o = shift;
	my $r = shift;
	
	return if $r->{'action'} ne 'save';
	
	if($r->{'question'}) #Нет вопроса - свалим.
	{
		my $to = fbQuestion->cre();
		my $res = $o->elem_paste($to);
		
		$to->admin_edit($r);
		$to->save();
		
		print '<div class="message">';
		
		if($res)
		{
			my $href = $o->root->{'address'}.$CMSBuilder::Config::http_aroot;
			$href =~ s'/+'/'g;
			
			if($o->papa()->{'emailme'})
			{
				sendmail
				(
					'to'	=> $o->root->{'email'},
					'from'	=> $to->{'username'}.' <'.($to->{'email'} || $o->root->{'email'}).'>',
					'subj'	=> 'Вопрос-ответ, тема:'.$o->name(),
					'text'	=> $to->{'question'}."\n\n--\n\nОтвет можно написать из админки: ".$href
				);
			}
			
			print
			'
			<p>Спасибо, ваш вопрос был успешно добавлен. Вы увидите его на сайте, когда он будет обработан.</p>
			'.($to->{'emailme'}?'<p>На указанный вами e-mail придёт уведомление об ответе.</p>':'').'
			<p><a href="'.$o->site_href().'?form=yes">Продолжить задавать вопросы...</a></p>
			';
		}
		else
		{
			print
			'
				К сожалению, по техническим причинам, ваш вопрос не был сохранен.
				Попробуйте отправить его по почте: <a href="mailto:',$o->root->{'email'},'">',$o->root->{'email'},'</a>.
			';
			
			return 0;
		}
		
		print '</div>';
	}
	else
	{
		print '<div class="error">Вы не ввели текст вопроса.</div>';
		return 0;
	}
	
	return 1;
}
#------------------------------------------------------------------------------------
#Скрывает строчку с номерами страниц во время составления вопроса.
sub site_pagesline
{
	my $o = shift;
	my $r = shift;
	
	return if $r->{'form'};
	
	return $o->SUPER::site_pagesline($r,@_);
}
#------------------------------------------------------------------------------------
#Распечатывает список тем. Если их слишком много, бьёт на страницы.
sub site_content
{
	my $o = shift;
	my $r = shift;
	
	if($r->{'form'})
	{
		return if $o->process_params($r);
		return $o->print_form($r);
	}
	
	my @page = $o->get_page($r->{'page'});
	
	print '<div class="mod-feedback">';
	
	print $o->access('a') ? '<p><a href="?form=yes">Задать вопрос...</a></p>' : '<p>Тема закрыта.</p>';
	
	if(!@page)
	{
		print '<div class="message">В этой теме нет вопросов.</div>';
	}
	else
	{
		map { $_->site_preview() } @page;
	}
	
	print '</div>';
}
#-------------------------------------------------------------------------------
sub print_form
{
	my $o = shift;
	my $r = shift;
	
	print
	'
	<form action="?" method="post">
		<input type="hidden" name="action" value="save">
		<input type="hidden" name="form" value="yes">
		
		<table>
		<tr>
			<td><label for="username">Ваше имя</label>:</td>
			<td><input name="username" value="',$r->{'username'},'"></td>
		</tr>
		<tr>
			<td><label for="email">Ваш e-mail</label>:<br/><small>(для администратора)</small></td>
			<td><input name="email" value="',$r->{'email'},'"></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><input id="checkbox_emailme" type="checkbox" ',$r->{'emailme'}?'checked="checked"':'',' name="emailme"><label for="checkbox_emailme">Оповестить об ответе на e-mail</label></td>
		</tr>
		<tr>
			<td><label for="question">Текст вопроса</label>:</td>
			<td><textarea cols="42" rows="15" name="question">',$r->{'question'},'</textarea></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><button type="submit">Задать вопрос</button></td>
		</tr>
		</table>
	</form>
	';
}
#-------------------------------------------------------------------------------
sub site_preview
{
	my $o = shift;
	
	print
	'
		<div class="theme-rpeview">
			<div class="name">'.$o->site_aname().'</div>
			'.($o->{'descr'}?'<div class="desc">'.$o->{'desc'}.'</div>':'').'
		</div>
	';
}
#-------------------------------------------------------------------------------
1;