# CMSBuilder © Леонов П. А., 2006

package modRecycleBin::Module;
use strict qw(subs vars);
use utf8;

use CMSBuilder::IO;
use modUsers::API;

our @ISA = qw(modAdmin::Tree CMSBuilder::DBI::Object CMSBuilder::Module);

sub _cname {'Корзина'}
sub _add_classes {'*'}
sub _one_instance {1}
sub _have_icon {'icons/RecycleBin.png'}


#-------------------------------------------------------------------------------

sub admin_name_ex_opts
{
	my $o = shift;
	return $user->{'recyclebin'} ? $user->{'recyclebin'}->admin_name_ex_opts : $o->SUPER::admin_name_ex_opts;
}

sub admin_right_href
{
	my $o = shift;
	return $user->{'recyclebin'}? $user->{'recyclebin'}->admin_right_href : $o->SUPER::admin_right_href;
}

sub admin_left_href
{
	my $o = shift;
	return $user->{'recyclebin'} ? $user->{'recyclebin'}->admin_left_href : $o->SUPER::admin_left_href;
}

sub admin_add_list {}

sub name
{
	my $o = shift;
	
	return $o->_cname(@_);# . '&nbsp;' . ($o->len ? '('.$o->len.')' : '(пусто)');
}

sub install_code
{
	my $c = shift;
	
	my $mr = modAdmin::modAdmin->root;
	
	my $to = $c->cre();
	$to->{'name'} = $c->cname();
	$to->save();
	
	$mr->elem_paste($to);
}

sub mod_load
{
	unshift @{$modAdmin::modAdmin::cmenus{'*'}}, \&my_context;
	unshift @CMSBuilder::DBI::Object::ISA, 'modRecycleBin::ObjectHook';
	unshift @modUsers::UserMember::ISA, 'modRecycleBin::UserHook';
}

sub my_context
{
	my $o = shift;
	
	return unless $o->access('w');
	return unless $user->{'recyclebin'};
	
	my $code;
	
	if($o->papa && $o->papa->isa('modRecycleBin::UserBin') and exists $sess->{$o->modrecyclebin_sesskey})
	{
		$code .=
		'
		elem_add(JMIHR());
		elem_add(JMIHref("Восстановить","right.ehtml?url='.$o->myurl.'&act=cms_restore_from_recyclebin","admin_temp"));
		';
	}
	elsif(!$o->papaN(0)->isa('modRecycleBin::UserBin'))
	{
		$code .=
		'
		elem_add(JMIHR());
		elem_add(JMIHref("В корзину","right.ehtml?url='.$o->myurl.'&act=cms_move_to_recyclebin","admin_temp"));
		';
	}
	
	return $code;
}


1;