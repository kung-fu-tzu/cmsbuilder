# (с) Леонов П.А., 2005

package JDBI::SimpleModule;
use strict qw(subs vars);
our @ISA = ('JDBI::Module','JDBI::NoBase','JDBI::Object');

sub _one_instance {1}
sub _cname {'Простой базовый модуль'}
# Простой модуль, состоит из функций (не содержит дерева)

#-------------------------------------------------------------------------------


sub name { return $_[0]->_cname(@_); }

sub admin_view_left
{
	my $o = shift;
	my $c = ref($o) || $o;
	my $cnt;
	
	print $c->admin_cname('Начало',$o->admin_right_href(),'admin_right'),'<br><br>';
	
	my $rpcf = $o->rpclist();
	
	for my $func (keys(%$rpcf))
	{
		if($c->can($func) && $rpcf->{$func}[0])
		{
			print $c->admin_cname($rpcf->{$func}[0],$o->admin_right_href().'&act='.$func,'admin_right',$rpcf->{$func}[1]?'icons/'.$rpcf->{$func}[1]:undef),'<br>';
			$cnt++;
		}
	}
	
	unless($cnt){ print 'У модуля нет функций для отображения.'; }
}

sub install_code
{
	my $mod = shift;
	
	my $mr = ModRoot->new(1);
	
	my $to = $mod->cre();
	$to->{'name'} = $mod->cname();
	$to->save();
	
	$mr->elem_paste($to);
}

1;