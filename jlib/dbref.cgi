package DBRef;
use strict qw(subs vars);

use vars '@ISA';
use vars '%props';
use vars '$name';
use vars '$AUTOLOAD';
use AutoLoader;

$name = 'Ярлык';

@ISA = 'DBObject';

%props = (
	
	'name'	  => { 'type' => 'string', 'length' => 100, 'name' => 'Название' },
	'ref_class'  => { 'type' => 'string', 'length' => 100, 'name' => 'Класс' },
	'ref_id'	  => { 'type' => 'int', 'name' => 'ID' }
);

###################################################################################################
# Следующие методы находятся в разработке
###################################################################################################



###################################################################################################
# Методы для реализации наследования Perl
###################################################################################################

sub AUTOLOAD
{
	my $o = shift;
	my $meth = $AUTOLOAD;
	$meth =~ s/.*:://;
	
	print STDERR $o->{'_class'}.'::'.$meth.'(\''.join("','",$o,@_).'\')';
	return &{$o->{'_class'}.'::'.$meth}($o,@_);
}

sub admin_name
{
	my $o = shift;
	my $ret;
	
	$ret = $o->name();
	
	$ret =~ s/\<(?:.|\n)+?\>//g;
	if(length($ret) > $DBArray::admin_left_max_name_len){ $ret = substr($ret,0,$DBArray::admin_left_max_name_len-1).'...' }
	
	return '<a id="id_DBRef'.$o->{'_ref_self_id'}.'" target="admin_right" href="right.ehtml?class=DBRef&ID='.$o->{'_ref_self_id'}.'">&nbsp;'.$ret.'&nbsp;</a>';
}

sub admin_tree
{
	my $o = shift;
	my $me = $o;
	
	my @all;
	my $count = 0;
	
	print '<script>',"\n";
	
	do{
		$count++;
		unshift(@all, $o->admin_name());
		
		print 'ShowMe(parent.frames.admin_left.document.all["dbi_'.$o->{'_class'}.$o->{'ID'}.'"],parent.frames.admin_left.document.all["dbdot_'.$o->{'_class'}.$o->{'ID'}.'"]); ',"\n";
		
	}while( $o = $o->papa() and $count < 50 );
	
	print 'SelectLeft(parent.frames.admin_left.document.all["id_DBRef'.$me->{'_ref_self_id'}.'"]);',"\n";
	
	print '</script>';
	
	print join(' :: ',@all);
}

sub del
{
	my $o = shift;
	my $i;
	
	print 'DELETING REF';
}

sub new
{
	my $o = {};
	bless($o);
	
	my $oo = $o->_construct(@_);
	$oo->ref_start();
	return $oo;
}

sub new_ref
{
	my $o = {};
	bless($o);
	
	my $id = shift;
	
	my $oo = $o->_construct($id);
	return $oo;
}

sub ref_take
{
	my $o = shift;
	my $ro = shift;
	
	if($o->{'_ref_started'}){ print STDERR 'Trying to take on started DBRef, $ro = '.$ro->myurl(); return; }
	
	$o->{'ref_class'} = $ro->{'_class'};
	$o->{'ref_id'} = $ro->{'ID'};
	$o->save();
}

sub ref_start
{
	my $o = shift;
	
	if($o->{'_ref_started'}){ return; }
	
	my $ref_class = $o->{'ref_class'};
	my $ref_id = $o->{'ref_id'};
	my $ref_self_id = $o->{'ID'};
	
	$o->clear();
	
	$o->{'_class'} = $ref_class;
	$o->{'ID'} = $ref_id;
	$o->{'_ref_self_id'} = $ref_self_id;
	$o->reload();

	$o->{'_ref_started'} = 1;	
}

sub ref_stop
{
	my $o = shift;
	
	if(!$o->{'_ref_started'}){ return; }
	
	my $ref_self_id = $o->{'_ref_self_id'};
	
	$o->save();
	$o->clear();
	
	$o->{'_class'} = ref($o);
	$o->{'ID'} = $ref_self_id;
	$o->reload();
}

sub DESTROY
{
	my $o = shift;
	$o->SUPER::DESTROY();
}


###################################################################################################
# Дополнительные методы
###################################################################################################

sub type { return 'DBRref'; }

return 1;