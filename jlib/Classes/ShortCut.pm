package ShortCut;
use strict qw(subs vars);

our $name = 'Ярлык';
our $isa = 'JDBI::Object';
our $page = '/page';
our @aview = qw/name obj_class obj_id/;
our $icon = 1;
our $AUTOLOAD;
our $meth;

our %props = (
	'name'		=> { 'type' => 'string', 'length' => 100, 'name' => 'Название' },
	'obj_class'	=> { 'type' => 'string', 'length' => 100, 'name' => 'Класс' },
	'obj_id'	=> { 'type' => 'int', 'name' => 'ID' }
);

our @sh_subs		= qw/ /;
our @sh_callback	=
qw/admin_tree admin_cmenu admin_tree admin_left admin_name
admin_arrayline enum admin_hicon del
on_Array_elem_moveto/;

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

sub admin_hicon { return '<img class="shcut_icon" align="absmiddle" src="img/shcut.gif">'; }

sub name
{
	my $o = shift;
	
	if($o->shcut_obj()){
		return $o->shcut_obj()->name(@_);
	}else{
		return $o->_meth('name',@_);
	}
}

sub admin_icon
{
	my $o = shift;
	
	if($o->shcut_obj()){
		return $o->shcut_obj()->admin_icon(@_);
	}else{
		return $o->_meth('admin_icon',@_);
	}
}

###################################################################################################
# Реализация извращённого ( мульти ;) ) наследования
###################################################################################################

sub AUTOLOAD
{
	my $co = shift;
	
	$AUTOLOAD =~ m/\:\:([^\:]+)/;
	$meth = $1;
	
	if(!ref($co) or $co->{'_callback'}){ return $co->_meth($meth,@_); }
	
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
	return $o->$meth(@_);
}

sub _callback
{
	my $o = shift;
	my $meth = shift;
	
	$meth = $isa.'::'.$meth;
	$o->{'_callback'}++;
	my $ret = $o->$meth(@_);
	$o->{'_callback'}--;
	return $ret;
}

return 1;