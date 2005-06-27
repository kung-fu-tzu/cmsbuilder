# (с) Леонов П.А., 2005

package JDBI::Module;
use strict qw(subs vars);

sub _cname {'Модуль'}
sub _classes {}			# Список используемых объектов
sub _one_instance {0}	# Если установлено в 1, то нельзя создавать два экземпляра модуля

#------------------------------------------------------------------------------

sub classes
{
	my $c = ref($_[0]) || $_[0];
	my $buff = $c.'::_classes_buff';
	
	if($$buff){ return @$$buff; }
	
	my @t = JDBI::Object::varr($c,'_classes');
	my @res;
	
	for my $v (reverse @t)
	{
		if($v eq '-'){ last; }
		unshift(@res,$v)
	}
	
	$$buff = [@res];
	return @$$buff;
}

sub install
{
	my $c = shift;
	
	if($JIO::modules_ini->{$c.'.installed'})
	{
		print $c->admin_cname(),' (+)<br>';
		return 0;
	}
	
	$c->install_code();
	print $c->admin_cname(),' (OK)<br>';
	$JIO::modules_ini->{$c.'.installed'} = 1;
	return 1;
}

sub mod_table_cre
{
	my $c = shift;
	my($cn,$is_ok);
	
	if($c->table_have()){ $is_ok = '+' }else{ $is_ok = 'OK' }
	
	print $c->admin_cname(),' (',$is_ok,')<br>';
	
	print '<div class="left_dir"><div class="left_dir">';
	
	for $cn ($c->classes())
	{
		if($cn->table_have())
		{
			$is_ok = '+';
		}
		else
		{
			$cn->table_cre();
			$is_ok = 'OK';
		}
		print $cn->admin_cname(),' (',$is_ok,')<br>';
	}
	
	print '</div></div><br>';
	
	return $c->table_cre(@_);
}

sub mod_table_fix
{
	my $c = shift;
	my($cn,$is_ok,$ret,$ch);
	
	if($c->table_have())
	{
		$ret = $c->table_fix(1);
		$is_ok = $ret?'OK':'+';
	}
	else
	{
		$c->table_cre(@_);
		$is_ok = 'TABLE';
	}
	if($is_ok ne '+'){ $ch = 1; }
	print $c->admin_cname(),' (',$is_ok,')','<br>';
	$c->table_fix();
	
	print '<div class="left_dir"><div class="left_dir">';
	
	for $cn ($c->classes())
	{
		if($cn->table_have())
		{
			$is_ok = $cn->table_fix(1)?'OK':'+';
		}
		else
		{
			$cn->table_cre(@_);
			$is_ok = 'TABLE';
		}
		if($is_ok ne '+'){ $ch = 1; }
		
		print $cn->admin_cname(),' (',$is_ok,')<br>';
		
		if($is_ok eq 'OK')
		{
			print '<div class="left_dir"><div class="left_dir"><div class="left_dir">';
			$cn->table_fix();
			print '</div></div></div>';
		}
	}
	
	print '</div></div><br>';
	
	return $ch;
}

sub type { return 'Module'; }

1;