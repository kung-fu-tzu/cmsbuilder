# CMSBuilder © Леонов П. А., 2005-2006

package CBM::Users;
use strict;
use utf8;

our @ISA = qw(Exporter);

use Exporter;

our @EXPORT =
qw(
	$user $group

	&access_off &access_on &access_ret
	&acs_off &acs_on &su_start &su_stop
	&is_guest &user_classes &user_classes_sel_one
);

use CMSBuilder;
use CMSBuilder::IO;
use CMSBuilder::Utils;

our
(
	@users_s,@udo_s,
	$errstr,
	
	$user,$group,
);



#————————————————————— Экпортируемые вспомогательные функции ———————————————————

sub is_guest
{
	my $u = shift;
	
	return ($u->parent && $u->parent->url eq cmsb_url($CMSBuilder::Config::user_guest)->parent->url)?1:0;
}

sub user_classes
{
	return grep {$_->isa('CBM::Users::UserMember')} cmsb_classes()
}

#—————————————————————— Экпортируемые базовые функции ——————————————————————————

sub access_off
{
	#CMSBuilder::ocache_clear();
	push @udo_s, $CMSBuilder::Config::access_on_e;
	$CMSBuilder::Config::access_on_e = 0;
}

sub access_on
{
	#CMSBuilder::ocache_clear();
	push @udo_s, $CMSBuilder::Config::access_on_e;
	$CMSBuilder::Config::access_on_e = 1;
}

sub access_ret
{
	#CMSBuilder::ocache_clear();
	unless(@udo_s){ return; }
	$CMSBuilder::Config::access_on_e = pop @udo_s;
}

sub acs_off(&)
{
	my $code = shift;
	access_off();
	my $ret = &$code;
	access_ret();
	return $ret;
}

sub acs_on(&)
{
	my $code = shift;
	access_on();
	my $ret = &$code;
	access_ret();
	return $ret;
}

sub su_start
{
	my $url = shift || $CMSBuilder::Config::user_admin;
	return unless $url;
	
	push @users_s, $user->url if $user;
	
	# Обнуляем для того, чтобы $user или $group не сохранялись
	# во время access_off(), что может привести к пересеченю зон
	$user = $group = undef;
	#CMSBuilder::ocache_clear();
	
	acs_off
	{
		$user = cmsb_url($url);
		return su_stop() unless $user;
		$group = $user->parent;
	};
	
	return 1;
}

sub su_stop
{
	unless(@users_s){ return 0; }
	
	# Обнуляем с той же целью, что и в su_start()
	$user = $group = undef;
	#CMSBuilder::ocache_clear();
	
	my $url = pop @users_s;
	
	acs_off
	{
		$user = cmsb_url($url);
		$group = $user->parent;
	};
}


sub user_classes_sel_one
{
	for my $cl (user_classes())
	{
		my $to = $cl->sel_one(@_);
		return $to if $to;
	}
	
	return;
}

#—————————————————————————— Дополнительные функции —————————————————————————————

sub init
{
	my $c = shift;
	
	$user = $group = undef;
	$errstr = undef;
	@users_s = @udo_s = ();
}

sub login
{
	my $c = shift;
	my $l = shift;
	my $p = shift;
	
	return err('Пустое имя пользователя или пароль.') unless $l && $p;
	
	my $tu;
	acs_off { $tu = user_classes_sel_one(' login = ? ',$l); };
	return err('Неверное имя пользователя.') unless $tu;
	
	unless($CMSBuilder::Config::users_pasoff)
	{
		return err('Неверный пароль.') unless $tu->{'pas'} eq MD5($p);
	}
	
	my $tg;
	my $ur;
	acs_off { $tg = $tu->parent; $ur = $tg->papa; };
	return err('Вы не состоите в группе.') unless $tg;
	return err('Группа не принадлежит авторизированному модулю.') unless $ur && $ur->url eq $CMSBuilder::Config::users_module;
	
	# Логин и пароль в порядке
	
	$sess->{'CBM::Users.uurl'} = $tu->url;
	su_start($tu->url);
	
	return 1;
}

sub logout
{
	my $c = shift;
	
	my $tu = cmsb_url($sess->{'CBM::Users.uurl'});
	return err("Вы не вошли в систему.") unless $tu;
	
	delete $sess->{'CBM::Users.uurl'};
	
	return 1;
}

sub verif
{
	my $c = shift;
	
	my $tu;
	acs_off { $tu = cmsb_url($sess->{'CBM::Users.uurl'}) };
	return unless $tu;
	
	my $tg;
	acs_off { $tg = $tu->parent };
	return unless $tg;
	
	su_start($tu->url);
	
	return 1;
}

sub last_error
{
	return $errstr;
}

sub err
{
	$errstr = shift;
	return 0;
}


1;