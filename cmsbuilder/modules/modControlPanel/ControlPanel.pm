# CMSBuilder © Леонов П. А., 2005-2006

package modControlPanel::ControlPanel;
use strict qw(subs vars);
use utf8;

our @ISA = qw(modAdmin::Simple CMSBuilder::Module);

use CMSBuilder;
use CMSBuilder::Utils;
use modUsers::API;
use modAccess::modAccess;

sub _cname {'Панель управления'}
sub _have_icon {'icons/ControlPanel.png'}
sub _one_instance {1}
sub _rpcs {qw(cpanel_table_cre), keys %{{_simplem_menu()}}}
sub _access_default {$AC_READ}

sub _simplem_menu
{
	cpanel_object_stat		=> { -name => 'Статистика объектов', -icon => 'icons/install.png' },
	cpanel_scanbase			=> { -name => 'Проверить базу', -icon => 'icons/table.png', -papa => 'cpanel_object_stat' },
	cpanel_table_fix		=> { -name => 'Обновить структуру', -icon => 'icons/table.png', -papa => 'cpanel_object_stat' },
	cpanel_modules			=> { -name => 'Модули', -icon => 'icons/install.png' },
	cpanel_install_mods		=> { -name => 'Поставить модули', -icon => 'icons/install.png', -papa => 'cpanel_modules' },
		
	$CMSBuilder::Config::server_type eq 'cgi-server' ? (cpanel_stopserver	=> { -name => 'Остановить сервер', -icon => 'icons/shutdown.png' }):(),
}

#———————————————————————————————————————————————————————————————————————————————


our	$refresh;

sub default
{
	print '«Панель управления» поможет вам централизовано настроить систему и получить подробную системную информацию.';
}

sub cpanel_modules
{
	print 'В разделе «Модули» можно добавлять, удалять и настраивать различные части системы.';
}

sub mod_is_installed { return 1; }
sub install_code {}

sub cpanel_stopserver
{
	my $pid = f2var($CMSBuilder::Config::server_pidfile);
	
	warn "Kiling server, pid: $pid";
	
	if(kill(KILL => $pid)){ print "Сервер успешно остановлен (KILL => $pid)."; }
	else{ print "Сервер остановить не удалось ($pid)."; }
}

sub admin_view_left
{
	my $o = shift;
	
	return CMSBuilder::IO::err403('Trying to cpanel, less $group->{"cpanel"}') unless $group->{'cpanel'};
	
	unless(modAdmin::modAdmin->root_class->table_have())
	{
		print '<br><center>Структура базы не установлена!</center>';
		return;
	}
	
	return $o->SUPER::admin_view_left(@_);
}

sub admin_view_right
{
	my $o = shift;
	
	return CMSBuilder::IO::err403('Trying to cpanel, less $group->{"cpanel"}') unless $group->{'cpanel'};
	
	$refresh = 0;
	
	my @res = $o->SUPER::admin_view_right(@_);
	
	unless(modAdmin::modAdmin->root_class->table_have())
	{
		print '<br><br>Структура базы не установлена! <a href="?url=',$o->myurl(),'&act=cpanel_table_cre"><b>Установить…</b></a>';
		return;
	}
	
	if($refresh){ print '<script language="JavaScript">parent.frames.admin_modules.document.location.href = parent.frames.admin_modules.document.location.href;</script>'; }
	
	return @res;
}

sub cpanel_scanbase
{
	my $o = shift;
	my $r = shift;
	my $cnt;
	
	print
	'
	<fieldset><legend>Параметры</legend>
		<form action="?">
			<input type="hidden" name="url" value="',$o->myurl(),'">
			<input type="hidden" name="act" value="cpanel_scanbase">
			<input type="hidden" name="do" value="yes">
			<div><input type="checkbox" name="roots" ',($r->{'roots'} && 'checked'),' id="cpanel_scanbase_roots"><label for="cpanel_scanbase_roots">включая корневые объекты</label></div>
			<div><input type="checkbox" name="loops" ',($r->{'loops'} && 'checked'),' id="cpanel_scanbase_loops"><label for="cpanel_scanbase_loops">выявлять замкнутые цепи</label></div>
			',($user->{'recyclebin'} && '<p><div><input type="checkbox" name="recycle" ',($r->{'recycle'} && 'checked'),' id="cpanel_scanbase_recycle"><label for="cpanel_scanbase_recycle">переместить все элементы к корзину</label></div></p>'),'
			<p><div><input type="checkbox" name="icons" ',($r->{'icons'} && 'checked'),' id="cpanel_scanbase_icons"><label for="cpanel_scanbase_icons">показать иконки управления</label></div></p>
			<p><button type="submit">Проверить…</button></p>
		</form>
	</fieldset>
	';
	
	if($r->{'do'})
	{
		print '<hr/><p>Проверяем базу…</p>';
		
		my $mr = modAdmin::modAdmin->root;
		
		print '<p><small>[Корень модулей не установлен]</small></p>' unless $mr;
		
		print '<dir>';
		for my $cn (cmsb_classes())
		{
			next if $cn->isa('modAdmin::Root');
			
			my @all = $cn->sel_where("1"); #PAPA = '' || PAPA = '0'
			my @tos;
			
			push @tos, grep { !($_->enum || $_->pname) } @all;
			push @tos, grep { !eval{$_->papaN(0)} } @all if $r->{'loops'};
			
			@tos = grep { !$_->isa('modAdmin::RootElement') && !$mr->elem_tell_enum($_) } @tos if !$r->{'roots'} && $mr;
			
			if(@tos)
			{
				print '<p><fieldset>';
				print '<legend>',$cn->cname,'</legend>';
				for my $to (@tos)
				{
					print '<div>', $to->can('admin_name') ? $to->admin_name : $to->name;
					print
					'
					<a href="',$to->admin_right_href,'&act=cms_elem_move2','"><img src="icons/move2.png"><a>
					<a href="',$to->admin_right_href,'&act=cms_elem_del','"><img src="icons/del.png"><a>
					'
					if $r->{'icons'};
					
					print '</div>';
					$cnt++;
				}
				print '</fieldset></p>';
				
				map { eval {$_->papa->elem_cut($_)}; eval {$user->{'recyclebin'}->elem_paste($_)} } @tos if $r->{'recycle'};
			}
			else
			{
				print '<div>',$cn->cname,'</div>';
			}
		}
		print '</dir>';
		
		print rus_case($cnt,["Нет потерянных объектов.","Обнаружен %d потерянный объект.","Обнаружено %d потерянных объекта.","Обнаружено %d потерянных объектов."]);
	}
}

sub cpanel_table_cre
{
	my $o = shift;
	
	CMSBuilder::DBI::access_creTABLE();
	modAdmin::modAdmin->root_class->table_cre();
	my $mr = modAdmin::modAdmin->root_class->cre();
	$mr->{'name'} = 'Корень модулей';
	$mr->papa_set($o);
	$mr->save();
	
	cpanel_table_fix();
	
	print
	'
	<p>Таблицы всех классов, таблица разрешений и корень модулей успешно установлены.</p>
	<p>Обычно, следующий шаг — это <a href="'.$o->admin_right_href().'&act=cpanel_install_mods"><u>Установка модулей</u></a>.</p>
	';
	$refresh = 1;
}

sub cpanel_table_fix
{
	my $ch;
	for my $cn (sort {$a->cname() cmp $b->cname()} cmsb_classes())
	{
		my $log = eval { $cn->table_fix() };
		
		print '<div><small style="float:right">';
		
		if($log->{'changed'} || $log->{'existed'} || $log->{'deleted'})
		{
			if($log->{'changed'})
			{
				print join ', ', map { '<strong>~'.$_->{'name'}.'</strong>[ '.$_->{'from'}.' &rarr; '.$_->{'to'}.' ]' } @{$log->{'changed'}};
			}
			if($log->{'existed'})
			{
				print join ', ', map { '<strong>+'.$_->{'name'}.'</strong>[ '.$_->{'to'}.' ]' } @{$log->{'existed'}};
			}
			if($log->{'deleted'})
			{
				print join ', ', map { '<strong>-'.$_->{'name'}.'</strong>[ '.$_->{'from'}.' ]' } @{$log->{'deleted'}};
			}
		}
		elsif($@)
		{
			print 'ошибка: ' . $@;
		}
		else
		{
			print 'порядок';
		}
		
		print '</small>',$cn->admin_cname(),'</div>';
		
		$ch += keys %$log;
	}
	
	print '<p>',$ch ? 'Структура обновлена.' : 'Обновление не требуется.','</p>';
}

sub cpanel_object_stat
{
	print '<table><tr><td align="center"><b>Класс</b></td><td width="25">&nbsp;</td><td><b>Кол-во</b></td></tr>';
	
	for my $cn (sort {$a->cname cmp $b->cname} cmsb_classes())
	{
		unless($cn){ print '<tr><td>&nbsp;</td><td></td><td></td></tr>'; next; }
		
		print '<tr><td>',$cn->admin_cname(),'</td><td></td><td align="center">',(${$cn.'::simple'}?'-':$cn->count()),'</td></tr>';
	}
	
	print '</table>';
}

sub cpanel_install_mods
{
	my $cnt;
	
	for my $mod (cmsb_modules()) #CMSBuilder::Admin->personal_modules()
	{
		my $res = $mod->mod_install();
		$cnt += $res;
		
		my $modname = $mod->can('admin_cname') ? $mod->admin_cname() : $mod->cname();
		
		print '<div>' . $modname . '<small style="float:right">' . ($res ? 'установлен' : 'порядок') . '</small></div>';
		$mod->err_print() if $mod->can('err_print');
	}
	
	if($cnt){ print '<p>Модули успешно установлены&nbsp;('.$cnt.').</p>'; } #$refresh = 1;
	else{ print '<p>Установка не требуется.</p>'; }
}


1;