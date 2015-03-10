# (�) ������ �.�., 2005

package ModRecycleBin;
use strict qw(subs vars);
our @ISA = 'JDBI::TreeModule';

sub _cname {'�������'}
sub _add_classes {'*'}

sub _rpcs
{
	'modrecyclebin_empty' => ['',''],
}

#-------------------------------------------------------------------------------


our $version = '1.5';
our $ini = JIO::Ini->new($JConfig::path_etc.'/ModRecycleBin.ini');

sub admin_cmenu_for_self
{
	my $o = shift;
	
	my @ret = $o->SUPER::admin_cmenu_for_self(@_);
	
	if($o->len())
	{
		print 'elem_add(JHR());';
		print 'elem_add(JMIDelete("��������","right.ehtml?url=',$o,'&act=modrecyclebin_empty"));';
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
	
	%$ini = ();
	
	$o->{'_print'} = '������� ������� �������';
	
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
	if($o->papa()->type() eq 'Object'){ return; }
	unless($o->papa()->elem_tell_enum($o)){ return; }
	
	if(ref($o->papaN(0)) eq 'ModRecycleBin')
	{
		if(ref($o->papa()) eq 'ModRecycleBin' and $ModRecycleBin::ini->{$o->myurl()})
		{
			print 'elem_add(JHR());';
			print 'elem_add(JMIHref("������������","right.ehtml?url=',$o->papa(),'&act=cms_restore_from_recyclebin&enum=',$o->enum(),'"));';
		}
	}
	else
	{
		print 'elem_add(JHR());';
		print 'elem_add(JMIHref("� �������","right.ehtml?url=',$o->papa(),'&act=cms_move_to_recyclebin&enum=',$o->enum(),'"));';
	}
}

sub cms_restore_from_recyclebin
{
	my $o = shift;
	my $r = shift;
	
	$o->{'_do_list'} = 1;
	
	my $e = $o->elem_cut($r->{'enum'});
	
	unless($ModRecycleBin::ini->{$e->myurl()})
	{
		$o->elem_paste($e);
		$o->err_add('���������� �������� �������������� �������.');
		return;
	}
	
	my $rp = JDBI::url($ModRecycleBin::ini->{$e->myurl()});
	$rp->elem_paste($e);
	
	delete $ModRecycleBin::ini->{$e->myurl()};
}

sub cms_move_to_recyclebin
{
	my $o = shift;
	my $r = shift;
	
	
	my $rb = ModRecycleBin->new(1);
	
	my $e = $o->elem_cut($r->{'enum'});
	$rb->elem_paste($e);
	
	$ModRecycleBin::ini = JIO::Ini->new($JConfig::path_etc.'/ModRecycleBin.ini');
	$ModRecycleBin::ini->{$e->myurl()} = $o->myurl();
	
	$o->{'_do_list'} = 1;
}


mod_init();

1;