# CMSBuilder © Леонов П. А., 2005-2006

package modAdmin::RootElement;
use strict qw(subs vars);
use utf8;

sub _cname {'Корневой элемент'} # Персональный модуль
sub _one_instance {0}	# Если установлено в 1, то нельзя создавать два экземпляра модуля
sub _have_icon {0}
sub _have_funcs {0}

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder::Utils;


sub admin_arrayline
{
	my $o = shift;
	my $a = shift;
	
	unless($a->isa(modAdmin::modAdmin->root_class)){ return; }
	
	unless($a->access('w')){ return; }
	unless($o->access('w')){ return; }
	
	my $enum = $a->elem_tell_enum($o);
	
	print '<a onclick="return deleteConfirm(\'',$o->name,'\')" href="'.$a->admin_right_href().'&act=cms_array_elem_delete&enum='.$enum.'"><img alt="Удалить" src="icons/del.png"></a>';
	
	print '<img src="img/nx.png">';
	
	print( ($enum == $a->len())?('<img src="img/nx.png">'):('<a href="'.$a->admin_right_href().'&act=cms_array_elem_down&enum='.$enum.'"><img alt="Переместить ниже" src="img/down.png"></a>') );
	print( ($enum == 1)?('<img src="img/nx.png">'):('<a href="'.$a->admin_right_href().'&act=cms_array_elem_up&enum='.$enum.'"><img alt="Переместить выше" src="img/up.png"></a>') );
	
	print '<img src="img/nx.png">';
}

sub have_funcs { return $_[0]->_have_funcs(@_); }

sub install_code
{
	my $mod = shift;
	
	my $mr = modAdmin::modAdmin->root;
	
	my $to = $mod->cre();
	$to->{'name'} = $mod->cname();
	$to->save();
	
	$mr->elem_paste($to);
}

sub mod_install
{
	my $c = shift;
	
	return if $c->mod_is_installed();
	
	$c->install_code();
	
	return 1;
}

sub mod_is_installed
{
	my $c = shift;
	
	my $mr = modAdmin::modAdmin->root;
	my @tos = grep { ref($_) eq $c } $mr->get_all();
	
	return (@tos > 0);
}



1;