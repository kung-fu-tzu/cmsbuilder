# (с) Леонов П.А., 2005

package ModRecycleBin;
use strict qw(subs vars);
our @ISA = 'JDBI::TreeModule';

sub _cname {'Корзина'}
sub _add_classes {'*'}

sub _rpcs
{
	'modrecyclebin_empty' => ['',''],
}

#-------------------------------------------------------------------------------


sub admin_cmenu_for_self
{
	my $o = shift;
	
	my @ret = $o->SUPER::admin_cmenu_for_self(@_);
	
	if($o->len())
	{
		print 'elem_add(JHR());';
		print 'elem_add(JMIDelete("Очистить","right.ehtml?url=',$o,'&act=modrecyclebin_empty"));';
	}
	
	return @ret;
}

sub admin_view
{
	my $o = shift;
	return $o->admin_array_view(@_);
}

sub admin_add_list {}

sub modrecyclebin_empty
{
	my $o = shift;
	
	for my $i (1..$o->len()){ $o->elem_del(1); }
	my $ini = JIO::Ini->new($JConfig::path_etc.'/ModRecycleBin.ini');
	%$ini = ();
	
	$o->{'_print'} = 'Корзина успешно очищена';
	
	$o->{'_do_list'} = 1;
}

sub name { return $_[0]->_cname(@_); }

sub install_code
{
	my $mod = shift;
	
	my $mr = ModRoot->new(1);
	
	my $to = $mod->cre();
	$to->{'name'} = $mod->cname();
	$to->save();
	
	$mr->elem_paste($to);
}


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------


package ModRecycleBin::rpchook;
use strict qw(subs vars);

sub _rpcs
{
	'cms_move_to_recyclebin' => ['',''],
	'cms_restore_from_recyclebin' => ['',''],
}

#-------------------------------------------------------------------------------


sub mod_init
{
	unshift @{$JDBI::cmenus{'*'}}, \&my_context;
	unshift @JDBI::CMS::ISA,__PACKAGE__;
}

sub my_context
{
	my $o = shift;
	
	unless($o->papa()){ return; }
	
	if(ref($o->papaN(0)) eq 'ModRecycleBin')
	{
		if(ref($o->papa()) eq 'ModRecycleBin')
		{
			print 'elem_add(JHR());';
			print 'elem_add(JMIHref("Восстановить","right.ehtml?url=',$o->papa(),'&act=cms_restore_from_recyclebin&enum=',$o->enum(),'&page=0"));';
		}
	}
	else
	{
		print 'elem_add(JHR());';
		print 'elem_add(JMIHref("В корзину","right.ehtml?url=',$o->papa(),'&act=cms_move_to_recyclebin&enum=',$o->enum(),'&page=0"));';
	}
}

sub cms_restore_from_recyclebin
{
	my $o = shift;
	my $r = shift;
	
	$o->{'_do_list'} = 1;
	
	my $ini = JIO::Ini->new($JConfig::path_etc.'/ModRecycleBin.ini');
	
	my $e = $o->elem_cut($r->{'enum'});
	
	my $rp = JDBI::url($ini->{$e->myurl()});
	
	unless($rp)
	{
		$o->elem_paste($e);
		$o->err_add('Неизвестно исходное местоположение объекта');
		return;
	}
	
	delete $ini->{$e->myurl()};
	
	$rp->elem_paste($e);
}

sub cms_move_to_recyclebin
{
	my $o = shift;
	my $r = shift;
	
	
	my $rb = ModRecycleBin->new(1);
	
	my $e = $o->elem_cut($r->{'enum'});
	$rb->elem_paste($e);
	
	my $ini = JIO::Ini->new($JConfig::path_etc.'/ModRecycleBin.ini');
	$ini->{$e->myurl()} = $o->myurl();
	
	$o->{'_do_list'} = 1;
}


mod_init();

1;