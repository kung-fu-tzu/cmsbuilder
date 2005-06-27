# (с) Леонов П.А., 2005

package ModRoot;
use strict qw(subs vars);
our @ISA = 'JDBI::Array';

sub _cname {'Раздел модулей'}
sub _add_classes {'*'}

#-------------------------------------------------------------------------------


sub name { return $_[0]->_cname(@_); }

sub elem_paste
{
	my $o = shift;
	
	my $ret = $o->SUPER::elem_paste(@_);
	
	my $to = $o->elem($o->len());
	$to->{'PAPA_CLASS'} = '';
	$to->{'PAPA_ID'} = '-1';
	$to->save();
	
	return $ret;
}

sub admin_add
{
	my $o = shift;
	my $c;
	
	print '
	<br><br>
	<table><tr>
	<td valign="top">Добавить:</td><td>';
	
	if($o->access('a'))
	{
		for $c (@JDBI::modules)
		{
			if(${$c.'::one_instance'}){ next }
			print $c->admin_cname('','right.ehtml?url='.$o->myurl().'&act=adde&cname='.$c),'<br>';
		}
	}
	print '</td></tr></table><br>';
}

sub access
{
	my $o = shift;
	my $type = shift;
	if($type eq 'r' or $type eq 'x'){ return 1; }
	return $o->SUPER::access($type,@_);
}

sub type { return 'ModRoot'; }

1;