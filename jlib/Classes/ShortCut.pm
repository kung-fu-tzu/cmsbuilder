# (с) Леонов П.А., 2005

package ShortCut;
use strict qw(subs vars);

sub _cname {'Ярлык'}
sub _aview {keys %{{_props()}}}

sub _props
{
	'name'		=> { 'type' => 'string', 'length' => 100, 'name' => 'Название' },
	'obj_class'	=> { 'type' => 'string', 'length' => 100, 'name' => 'Класс' },
	'obj_id'	=> { 'type' => 'int', 'name' => 'ID' }
}

#-------------------------------------------------------------------------------


our $isa = 'JDBI::Object';
our $AUTOLOAD;
our @sh_subs		= qw/ /;
our @sh_callback	=
qw/
	admin_path admin_cmenu admin_left_tree admin_view_left admin_name
	admin_arrayline enum admin_hicon del
	on_Array_elem_moveto
/;

###################################################################################################
# Собственные методы ярлыка
###################################################################################################

sub shcut_obj
{
	my $o = shift;
	if($o->{'_o'}){ return $o->{'_o'}; }
	unless($o->{'obj_class'} or $o->{'obj_id'}){ return undef; }
	
	$o->{'_o'} = $o->{'obj_class'}->new($o->{'obj_id'});
	
	return $o->{'_o'};
}

sub shcut_save
{
	my $o = shift;
	return $o->_callback('save',@_);
}

sub admin_hicon { return '<img class="shcut_icon" align="absmiddle" src="icons/shcut.gif">'; }

sub name
{
	my $o = shift;
	
	if($o->shcut_obj())
	{
		return $o->shcut_obj()->name(@_);
	}
	else
	{
		return $o->_meth('name',@_);
	}
}

sub admin_icon
{
	my $o = shift;
	
	if($o->shcut_obj())
	{
		return $o->shcut_obj()->admin_icon(@_);
	}
	else
	{
		return $o->_meth('admin_icon',@_);
	}
}

###################################################################################################
# Реализация условного наследования
###################################################################################################

sub AUTOLOAD
{
	my $co = shift;
	
	$AUTOLOAD =~ m/\:\:(.+?)$/;
	my $meth = $1;
	
	if(!ref($co) || $co->{'_callback'}){ return $co->_meth($meth,@_); }
	
	if(JDBI::indexA($meth,@sh_subs) >= 0){ return $co->_meth($meth,@_); }
	if(JDBI::indexA($meth,@sh_callback) >= 0){ return $co->_callback($meth,@_); }
	
	if($co->shcut_obj()){ return $co->shcut_obj()->$meth(@_); }
	
	return $co->_meth($meth,@_);
}

sub _meth
{
	my $o = shift;
	my $meth = shift;
	
	$meth = $isa.'::'.$meth;
	return ($o->$meth(@_));
}

sub _callback
{
	my $o = shift;
	my $meth = shift;
	
	$o->{'_callback'}++;
	my @ret = $o->_meth($meth,@_);
	$o->{'_callback'}--;
	return @ret;
}

sub DESTROY { $_[0]->shcut_save(); }

use overload ('""' => \&as_string);

1;