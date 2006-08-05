# (с) Токмаков А. И., 2006

package fbQuestion;
use strict qw(subs vars);
use utf8;

our @ISA = ('modSite::Object','CMSBuilder::DBI::Object');

sub _cname {'Вопрос'}
sub _aview {qw/username email emailme question answer emailed/}

sub _props
{
	'username'		=> { 'type' => 'string', 'length' => 20, 'name' => 'Имя пользователя'},
	'email'			=> { 'type' => 'string', 'length' => 50, 'name' => 'e-mail' },
	'emailme'		=> { 'type' => 'checkbox', 'name' => 'Сообщить об ответе на e-mail' },
	'emailed'		=> { 'type' => 'checkbox', 'name' => 'Уведомление отправлено' },
	'question'		=> { 'type' => 'text', 'name' => 'Ваш вопрос' },
	'answer'		=> { 'type' => 'text', 'name' => 'Ответ' }
}

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder::Utils;
use CMSBuilder::IO::Session;

sub _have_icon 
{
	my $o = shift;
	
	return $o->{'answer'}?'icons/fb_quest.gif':'icons/fb_quest_new.gif';
}

sub name
{
	my $o = shift;
	return substr($o->{'question'},0,25).(length($o->{'question'})>25?'...':'');
}

sub site_head {}

sub admin_edit
{
	my $o = shift;
	my $r = shift;
	
	my $res = $o->SUPER::admin_edit($r,@_);
	
	if($o->{'emailme'} && $o->{'email'} && $o->{'answer'} && !$o->{'emailed'})
	{
		my $question = $o->{'question'};
		$question =~ s/^/\> /g;
		
		my $sended = sendmail
		(
			'to'	=> $o->{'email'},
			'from'	=> $o->root->{'email'},
			'subj'	=> '['.$o->root->{'bigname'}.'] Re: '.$o->papa()->name(),
			'text'	=> $question."\n\n".$o->{'answer'}."\n\n--\n\nОригинал: ".$o->site_abshref
		);
		
		if($sended)
		{
			$o->notice_add('Пользователю отправлено уведомление.');
			$o->{'emailed'} = 1;
		}
		else
		{
			$o->err_add('Ошибка отправки уведомления.');
		}
	}
	
	$sess->{'admin_refresh_left'} = 1;
	
	return $res;
}
#-------------------------------------------------------------------------------
sub site_preview
{
	my $o = shift;
	
	print
	'
		<div class="mod-feedback-question">
			<div class="question">
				<div class="head">Вопрос'.($o->{'username'}?' от пользователя &laquo;'.$o->{'username'}.'&raquo;':'').': </div>
				<div class="text">'.$o->{'question'}.'</div>
			</div>
			<div class="answer">
				<div class="head">Ответ: </div>
				<div class="text">'.$o->{'answer'}.'</div>
			</div>
		</div>
	';
}
#-------------------------------------------------------------------------------
sub site_content
{
	my $o = shift;
	return $o->site_preview(@_);
}
#-------------------------------------------------------------------------------
1;