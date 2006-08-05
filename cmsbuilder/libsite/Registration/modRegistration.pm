# (с) Леонов П.А., 2005

package modRegistration;
use strict qw(subs vars);
use utf8;

our @ISA = qw(modSite::Member CMSBuilder::DBI::Array CMSBuilder::Admin::Tree CMSBuilder::Module);

sub _cname {'Регистрация'}
sub _add_classes {qw/!*/}
sub _have_icon {1}
sub _pages_direction {0}
sub _aview{qw/group class/}
sub _template_export {qw/userform/}

sub _props
{
	'class'	=> { 'type' => 'ClassesList', 'class' => 'modUsers::UserMember', 'name' => 'Класс пользователей' },
	'group'	=> { 'type' => 'ObjectsList', 'class' => 'UserGroup', 'name' => 'Создавать в группе' },
}

#———————————————————————————————————————————————————————————————————————————————

use modUsers;
use CMSBuilder::Utils;


sub userform
{
	my $o = shift;
	my $r = shift;
	
	if(is_guest($user))
	{
		print
		'
		<div class="mod-registration">
			<form action="',$o->site_href(),'" method="post">
				<div>Вход для пользователя</div>
				<div class="login">Логин: <input name="login"/></div>
				<div class="password">Пароль: <input name="password"/></div>
				<button type="submit">Войти</button>
				<input type="hidden" name="act" value="login"/>
				<div class="register"><a href="',$o->site_href(),'?act=register">Зарегистрироваться...</a></div>
			</form>
		</div>
		';
	}
	else
	{
		print
		'
		<div class="mod-registration">
			<div class="welcome">Добро пожаловать!</div>
			<div class="username">Вы вошли под именем: <a href="',$user->site_href(),'">',$user->name(),'</a></div>
			<div class="exit"><a href="',$o->site_href(),'?act=logout">Выйти</a></div>
		</div>
		';
	}
}

sub site_content
{
	my $o = shift;
	my $r = shift;
	
	print '<div class="mod-registration">';
	
	if($r->{'act'} eq 'remind')
	{
		if($r->{'key'})
		{
			my $tu;
			acs_off { $tu = user_classes_sel_one(' remind = ? ',$r->{'key'}) };
			
			unless($tu)
			{
				print '<div class="message">Нет такого ключа или ключ уже был использован.</div>';
				return;
			}
			
			$tu->{'remind'} = '';
			$tu->{'pas'} = genpas();
			
			acs_off { $tu->save() };
			
			print '<div class="message">Ваш новый пароль: <strong>',$tu->{'pas'},'</strong>.</div>';
			
			return;
		}
		
		my $tu;
		acs_off { $tu = user_classes_sel_one(' login = ? ',$r->{'email'}) };
		
		unless($tu)
		{
			print '<div class="message">Нет такого пользователя.</div>';
			return;
		}
		
		srand;
		my $key = MD5($r->{'email'}.rand().[]);
		
		$tu->{'remind'} = $key;
		acs_off { $tu->save() };
		
		sendmail
		(
			'to' => $r->{'email'},
			'from' => $o->root->{'email'},
			'subj' => '['.$o->root->{'bigname'}.'] Ключ для смены пароля',
			'text' => 'Перейдите по ссылке для смены пароля: '.$o->site_abshref().'?act=remind&key='.$key
		);
		
		print '<div class="message">Ключ успешно выслан.</div>';
	}
	
	if($r->{'act'} eq 'register')
	{
		unless(is_guest($user))
		{
			print '<div class="message">Вы уже зарегистрировались и вошли в систему.</div>';
			return;
		}
		
		if(user_classes_sel_one(' login = ? ',$r->{'email'}))
		{
			print
			'
			<div class="message"><span class="head">Ошибка!</span> Пользователь с такой почтой уже существует.</div>
			<p>Система может <a href="',$o->site_href(),'?act=remind&email=',$r->{'email'},'">выслать ключ</a> на этот почтовый ящик. Ключ поможет сменить пароль.</p>
			';
			return;
		}
		
		if($r->{'email'})
		{
			my $tu;
			acs_off
			{
				$tu = $o->{'class'}->cre();
				$tu->{'login'} = $tu->{'email'} = $r->{'email'};
				$tu->{'pas'} = genpas();
				$tu->save();
				$o->{'group'}->elem_paste($tu);
			};
			
			modUsers->login($tu->{'login'},$tu->{'pas'});
			
			sendmail
			(
				'to' => $r->{'email'},
				'from' => $o->root->{'email'},
				'subj' => '['.$o->root->{'bigname'}.'] Регистрация',
				'text' => 'Ваш логин: '.$tu->{'login'}."\n".'Ваш пароль: '.$tu->{'pas'}
			);
			
			print
			'
			<p>Письмо успешно отправлено. Регистрация завершена.</p>
			<p>Вы автоматически вошли под этим логином.</p>
			';
		}
		else
		{
			print
			'
			<div class="mod-registration">
				<div class="register">
					<form action="',$o->site_href(),'" method="post">
						<div class="email">Почта: <input name="email"/></div>
						<button type="submit">Зарегистрироваться</button>
						<input type="hidden" name="act" value="register"/>
						<p>Адрес почты будет вашим логином, а пароль прийдет на почту.</p>
					</form>
				</div>
			</div>
			';
		}
	}
	
	if($r->{'act'} eq 'login')
	{
		if(modUsers->login($r->{'login'},$r->{'password'}))
		{
			print '<script>location.href = "/"</script>';
		}
		else
		{
			print '<div class="message"><span class="head">Ошибка!</span> ',modUsers->last_error(),'</div>';
		}
	}
	
	if($r->{'act'} eq 'logout')
	{
		if(modUsers->logout())
		{
			print '<script>location.href = "/"</script>';
		}
		else
		{
			print '<div class="message"><span class="head">Ошибка!</span> ',modUsers->last_error(),'</div>';
		}
	}
	
	print '</div>';
}

sub genpas
{
	srand;
	return substr(MD5(rand().{}.rand()),0,9)
}

sub install_code {}
sub mod_is_installed {1}

1;