# CMSBuilder © Леонов П. А., 2005-2006

package modRegistration::Client;
use strict qw(subs vars);
use utf8;

our @ISA = qw(modForms::Interface modUsers::UserMember CMSBuilder::DBI::Object);

sub _cname {'Клиент'}
sub _aview
{qw(
 login pas orders
 email email2
 fam name second bdate sex
 country city street building zip tel fax
)}

sub _sview
{qw(
 email email2
 fam name second bdate sex
 country city street building zip tel fax
)}

sub _props
{
	orders		=> { type => 'shcut', name => 'Заказы' },
	
	email		=> { type => 'string', name => 'E-mail' },
	email2		=> { type => 'string', name => 'Дополнительный&nbsp;e-mail' },
	
	fam			=> { type => 'string', check => '\S', name => 'Фамилия' },
	name		=> { type => 'string', check => '\S', name => 'Имя' },
	second		=> { type => 'string', check => '\S', name => 'Отчество' },
	bdate		=> { type => 'string', check => '\d\d.\d\d.\d\d\d\d', name => 'Дата&nbsp;рождения' },
	sex			=> { type => 'select', variants => [{none => 'не скажу'},{male => 'парень'},{female => 'девушка'}], name => 'Пол' },
	
	country		=> { type => 'string', name => 'Страна' },
	city		=> { type => 'string', name => 'Город' },
	street		=> { type => 'string', name => 'Улица дом/корпус' },
	building	=> { type => 'string', name => 'Номер&nbsp;дома/Корпус.строение/Квартира' },
	zip			=> { type => 'string', name => 'Почтовый&nbsp;индекс' },
	tel			=> { type => 'string', name => 'Телефон' },
	fax			=> { type => 'string', name => 'Факс' },
}

#———————————————————————————————————————————————————————————————————————————————


use modUsers::API;
use CMSBuilder::Utils;


sub site_page
{
	my $o = shift;
	
	return if $o->forms_site_page(@_);
	return $o->SUPER::site_page(@_);
}

sub site_content
{
	my $o = shift;
	my $r = shift;
	
	return if $o->forms_site_content($r,@_);
	
	if($o->access('r'))
	{
		print parsetpl
		'
		Имя: ${name}<br/>
		Дата регистрации: ${date}<br/>
		'
		,{%$o,'date'=>$o->site_cdate()};
		
		print '<p>Вы можете <a href="'.$o->site_href.'?form-act=edit">редактировать анкету</a></p>' if $o->access('w');
	}
}

sub name
{
	my $o = shift;
	
	return $o->{'name'} || $o->{'login'} || $o->{'email'} if $o->access('w');
	return $o->SUPER::name();
}

sub access
{
	my $o = shift;
	my $type = shift;
	
	return 1 if $type eq 'w' && $user->myurl() eq $o->myurl();
	
	return $o->SUPER::access($type,@_);
}

1;