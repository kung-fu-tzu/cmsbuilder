package StdModule;
use strict qw(subs vars);
our @ISA = 'JDBI::Array';

our $name = 'Базовый модуль';
our @classes;		# Список используемых объектов
our $one_instance;	# Нельзя создавать два экземпляра модуля
our $simple;		# Простой модуль, состоит из функций (не содержит дерева)

sub install
{
	my $class = shift;
	
	unless($class->can('install_code')){
		print $class->admin_cname(),' (+-)<br>';
		return 0;
	}
	
	if($JIO::modules_ini->{$class.'.installed'}){
		print $class->admin_cname(),' (+)<br>';
		return 0;
	}
	
	$class->install_code();
	print $class->admin_cname(),' (OK)<br>';
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
		return $o->SUPER::admin_right_href(@_);
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
	
	print $class->admin_cname(),' (',$is_ok,')<br>';
	
	print '<div class="left_dir"><div class="left_dir">';
	
	for $cn (@{$class.'::classes'}){
		
		if($cn->table_have()){
			$is_ok = '+';
		}else{
			$cn->table_cre();
			$is_ok = 'OK';
		}
		print $cn->admin_cname(),' (',$is_ok,')<br>';
		
	}
	
	print '</div></div><br>';
	
	return $class->SUPER::table_cre(@_);
}

sub table_fix
{
	my $class = shift;
	my($cn,$is_ok,$ret,$ch);
	
	if($class->table_have()){
		$ret = $class->SUPER::table_fix(1);
		$is_ok = $ret?'OK':'+'; 
	}else{
		$class->SUPER::table_cre(@_);
		$is_ok = 'TABLE';
	}
	if($is_ok ne '+'){ $ch = 1; }
	print $class->admin_cname(),'<br>';
	$class->SUPER::table_fix();
	
	print '<div class="left_dir"><div class="left_dir">';
	
	for $cn (@{$class.'::classes'}){
		
		if($cn->table_have()){
			$is_ok = $cn->table_fix(1)?'OK':'+';
		}else{
			$cn->table_cre(@_);
			$is_ok = 'TABLE';
		}
		if($is_ok ne '+'){ $ch = 1; }
		
		print $cn->admin_cname(),' (',$is_ok,')<br>';
		
		if($is_ok eq 'OK'){
			print '<div class="left_dir"><div class="left_dir"><div class="left_dir">';
			$cn->table_fix();
			print '</div></div></div>';
		}
	}
	
	print '</div></div><br>';
	
	return $ch;
}

sub type { return 'Module'; }

return 1;



