package StdModule;
use strict qw(subs vars);
our @ISA = 'JDBI::Array';

our $name = 'Базовый модуль';
our @classes;	  # Список используемых объектов
our $one_instance; # Нельзя создавать два экземпляра модуля
our $simple;	   # Простой модуль, состоит из функций (не содержит дерева)

sub install
{
	my $class = shift;
	
	unless($class->can('install_code')){
		print 'Модуль "<nobr style="CURSOR: default"><img align="absmiddle" src="',$class->admin_icon(),'">&nbsp;&nbsp;',${$class.'::name'},'" не требует установки.</nobr><br>';
		return 0;
	}
	
	if($JIO::modules_ini->{$class.'.installed'}){
		print 'Модуль "<nobr style="CURSOR: default"><img align="absmiddle" src="',$class->admin_icon(),'">&nbsp;&nbsp;',${$class.'::name'},'" уже установлен.</nobr><br>';
		return 0;
	}
	
	$class->install_code();
	$JIO::modules_ini->{$class.'.installed'} = 1;
	return 1;
}

sub admin_modr
{
	my $o = shift;
	
	print '<b>',$o->{'name'},'</b> admin_modr для класса "',ref($o),'" не определён!';

}

sub admin_modl
{
	my $o = shift;
	
	print '<b>',$o->{'name'},'</b> admin_modl для класса "',ref($o),'" не определён!';

}

sub admin_right_href
{
	my $o = shift;
	if(${ref($o).'::simple'}){
		return 'modr.ehtml?url='.$o->myurl();
	}else{
		return $o->admin_href(@_);
	}
}

sub admin_left_href
{
	my $o = shift;
	if(${ref($o).'::simple'}){
		return 'modl.ehtml?url='.$o->myurl();
	}else{
		return 'left.ehtml?url='.$o->myurl();
	}
}

sub table_cre
{
	my $class = shift;
	my($cn,$is_ok);
	
	if($class->table_have()){ $is_ok = '+' }else{ $is_ok = 'OK' }
	
	print '<nobr style="CURSOR: default"><img align="absmiddle" src="',$class->admin_icon(),'">&nbsp;&nbsp;&nbsp;',${$class.'::name'},' (',$is_ok,')</nobr><br>';
	
	print '<div class="left_dir"><div class="left_dir">';
	
	for $cn (@{$class.'::classes'}){
		
		if($cn->table_have()){
			$is_ok = '+';
		}else{
			$cn->table_cre();
			$is_ok = 'OK';
		}
		print '<nobr style="CURSOR: default"><img align="absmiddle" src="',$cn->admin_icon(),'">&nbsp;&nbsp;&nbsp;',${$cn.'::name'},' (',$is_ok,')</nobr><br>';
		
	}
	
	print '</div></div><br>';
	
	return $class->SUPER::table_cre(@_);
}

sub table_fix
{
	my $class = shift;
	my($cn,$is_ok,$ret);
	
	if($class->table_have()){
		$ret = $class->SUPER::table_fix(@_);
		$is_ok = $ret?'OK':'+'; 
	}else{
		$class->SUPER::table_cre(@_);
		$is_ok = 'TABLE'
	}
	
	print '<nobr style="CURSOR: default"><img align="absmiddle" src="',$class->admin_icon(),'">&nbsp;&nbsp;&nbsp;',${$class.'::name'},' (',$is_ok,')</nobr><br>';
	
	print '<div class="left_dir"><div class="left_dir">';
	
	for $cn (@{$class.'::classes'}){
		
		if($cn->table_have()){
			$is_ok = $cn->table_fix(1)?'OK':'+';
		}else{
			$cn->table_cre(@_);
			$is_ok = 'TABLE';
		}
		print '<nobr style="CURSOR: default"><img align="absmiddle" src="',$cn->admin_icon(),'">&nbsp;&nbsp;&nbsp;',${$cn.'::name'},' (',$is_ok,')</nobr><br>';
		
		if($is_ok eq 'OK'){
			print '<div class="left_dir"><div class="left_dir"><div class="left_dir">';
			$cn->table_fix();
			print '</div></div></div>';
		}
	}
	
	print '</div></div><br>';
	
	return $ret;
}

sub type { return 'Module'; }

return 1;



