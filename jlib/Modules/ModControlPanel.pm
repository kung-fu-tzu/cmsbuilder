# (с) Леонов П.А., 2005

package ModControlPanel;
use strict qw(subs vars);
our @ISA = 'JDBI::SimpleModule';

sub _cname {'Панель управления'}
sub _icon {1}
sub _one_instance {1}

sub _rpcs
{
	'cpanel_table_cre'		=> ['',''],
	'cpanel_table_fix'		=> ['Обновить структуру...','table.gif'],
	'cpanel_object_stat'	=> ['Статистика объектов','install.gif'],
	'cpanel_install_mods'	=> ['Поставить модули...','install.gif'],
	'cpanel_backup'			=> ['Резервная копия','backup.gif'],
	'cpanel_mod_root'		=> ['Корень модулей','ModRoot.gif'],
	#'cpanel_scanbase'		=> ['Проверить базу...','install.gif'],
	''	=> [],
	''	=> [],
}

our	$refresh;

sub default
{
	print 'Модуль "Панель управления" помогает Вам централизовано настраивать систему и получать системную информацию.';
}

sub admin_view_left
{
	my $o = shift;
	
	unless(ModRoot->table_have())
	{
		print '<br><center>Структура базы не установлена!</center>';
		return;
	}
	
	return $o->SUPER::admin_view_left(@_);
}

sub admin_view_right
{
	my $o = shift;
	
	unless($JDBI::group->{'root'})  { JIO::err403('Trying to cpanel, less $JDBI::group->{"root"}'); return; }
	unless($JDBI::group->{'cpanel'}){ JIO::err403('Trying to cpanel, less $JDBI::group->{"cpanel"}'); return; }
	
	$refresh = 0;
	
	my @res = $o->SUPER::admin_view_right(@_);
	
	unless(ModRoot->table_have())
	{
		print '<br><br>Структура базы не установлена! <a href="?url=',$o->myurl(),'&act=cpanel_table_cre"><b>Установить...</b></a>';
		return;
	}
	
	if($refresh){ print '<script language="JavaScript">parent.frames.admin_modules.document.location.href = parent.frames.admin_modules.document.location.href;</script>'; }
	
	return @res;
}

sub cpanel_scanbase
{
	my $o = shift;
	
	for my $cn (JDBI::allclasses())
	{
		for my $to ($cn->sel_where(" PAPA_CLASS = '' OR PAPA_ID = 0 "))
		{
			print $to->name(),'<br>';
		}
	}
}

sub cpanel_mod_root
{
	my $mr = ModRoot->new(1);
	$mr->admin_view();
}

sub cpanel_table_cre
{
	$refresh = 1;
	
	JDBI::access_creTABLE();
	ModRoot->table_cre();
	my $mr = ModRoot->cre();
	$mr->{'name'} = 'Корень модулей';
	$mr->save();
	
	print 'Таблицы всех классов, таблица разрешений и корень модулей успешно установлены.<br><br>';
	
	for my $mod (@JDBI::modules){ $mod->mod_table_cre() }
}

sub cpanel_table_fix
{
	my $ch;
	for my $mod (@JDBI::modules){ $ch |= $mod->mod_table_fix(); }
	
	print '<br>';
	if($ch){ print 'Структура обновлена.'; }
	else{ print 'Обновление не требуется.'; }
}

sub cpanel_object_stat
{
	print '<br><table><tr><td align="center"><b>Класс</b></td><td width="25">&nbsp;</td><td><b>Кол-во</b></td></tr>';
	
	for my $mod (@JDBI::modules,'',@JDBI::classes)
	{
		unless($mod){ print '<tr><td>&nbsp;</td><td></td><td></td></tr>'; next; }
		
		print '<tr><td>',$mod->admin_cname(),'</td><td></td><td align="center">',(${$mod.'::simple'}?'-':$mod->count()),'</td></tr>';
	}
	
	print '</table>';
}

sub cpanel_install_mods
{
	my $some = 0;
	
	for my $mod (@JDBI::modules){ $some |= $mod->install(); }
	
	if($some){ print '<br>Модули успешно установлены.'; $refresh = 1; }
	else{ print '<br>Установка не требуется.'; }
}

sub cpanel_backup
{
	my $o = shift;
	my $r = shift;
	my $sact = $r->{'sact'};
	
	my $confname = 'config_v1.0.txt';
	
	if($sact eq 'do')
	{
		my($sql,$mb,@mbs,$zfname,$conf);
		use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
		use POSIX ('strftime');
		
		unless(-d $JConfig::path_backup){ mkdir($JConfig::path_backup); }
		
		my $zip = Archive::Zip->new();
		
		if($r->{'sql'})
		{
			$sql = `$JConfig::mysql_dumpcmd`;
			$zip->addString($sql,'sql.txt');
		}
		
		if($r->{'www'})
		{
			my $rule = sub { $_ !~ /$JConfig::path_htdocs($JConfig::http_aroot)|($JConfig::http_eroot)/ };
			$zip->addTree($JConfig::path_htdocs,'www',$rule);
		}
		
		if($r->{'ee'})
		{
			$zip->addTree($JConfig::path_htdocs.$JConfig::http_eroot,'ee');
		}
		
		if($r->{'admin'})
		{
			$zip->addTree($JConfig::path_htdocs.$JConfig::http_aroot,'admin');
		}
		
		if($r->{'etc'})
		{
			$zip->addTree($JConfig::path_etc,'etc');
		}
		
		if($r->{'tmp'})
		{
			$zip->addTree($JConfig::path_tmp,'tmp');
		}
		
		if($r->{'code'})
		{
			$zip->addTree($JConfig::path_lib,'code/jlib');
			$zip->addFile('eml.cgi','code/eml.cgi');
		}
		
		$conf .= ', '.join(', ',keys(%$r));
		$conf =~ s/(, )*(act|sact|send)//g;
		$conf =~ s/^\, //;
		$zip->addString($conf,$confname);
		
		for $mb ($zip->members())
		{
			$mb->desiredCompressionMethod(COMPRESSION_DEFLATED);
			$mb->desiredCompressionLevel(COMPRESSION_LEVEL_BEST_COMPRESSION);
		}
		
		$zfname = $JConfig::mysql_base.'.'.strftime('%Y-%m-%d.%H-%M-%S',localtime()).'.zip';
		if($zip->writeToFileNamed($JConfig::path_backup.'/'.$zfname) == AZ_OK)
		{
			print '<br>Архив успешно создан: <b>'.$zfname.'</b> ('.JDBI::len2size((stat($JConfig::path_backup.'/'.$zfname))[7]).').';
			if($r->{'send'}){ print '<iframe height="0" width="0" src="?act=backup&sact=send&fname=',$zfname,'"></iframe>'; }
		}
		else{ print 'Не удалось сохранить файл архива!'; }
	}
	elsif($sact eq 'upload')
	{
		my($zf);
		my $bfile = CGI::param('bfile');
		my $tmpz = $JConfig::path_backup.'/temp'.$$.'.zip';
		
		open($zf,'>',$tmpz);
		binmode($zf);
		binmode($bfile);
		my $buff;
		while(read($bfile,$buff,2048)){ print $zf $buff; }
		close($zf);
		
		my $zip = Archive::Zip->new();
		$zip->read($tmpz);
		
		unless($zip->memberNamed($confname)){ print 'Неверный формат файла!<br>'; return; }
		
		JIO->stop();
		
		my $conf = $zip->contents($confname);
		
		if($conf =~ /sql/)
		{
			my $sql = $zip->contents('sql.txt');
			
			while($sql =~ m/CREATE TABLE (\S+) \(\n/g)
			{
				$JDBI::dbh->do('DROP TABLE IF EXISTS '.$1);
			}
			
			my $fh;
			open($fh,'|-',$JConfig::mysql_importcmd);
			print $fh $sql;
			close($fh);
		}
		
		if($conf =~ /www/)
		{
			$zip->extractTree('www',$JConfig::path_htdocs);
			print 'Дизайн восcтановлен.<br>';
		}
		
		if($conf =~ /ee/)
		{
			$zip->extractTree('ee',$JConfig::path_htdocs.$JConfig::http_eroot);
			print 'Файлы пользователей восcтановлены.<br>';
		}
		
		if($conf =~ /admin/)
		{
			$zip->extractTree('admin',$JConfig::path_htdocs.$JConfig::http_aroot);
			print 'Админка восcтановлена.<br>';
		}
		
		if($conf =~ /etc/)
		{
			$zip->extractTree('etc',$JConfig::path_etc);
			print 'Служебные файлы восcтановлены.<br>';
		}
		
		if($conf =~ /tmp/)
		{
			$zip->extractTree('tmp',$JConfig::path_tmp);
			print 'Временные файлы воcстановлены.<br>';
		}
		
		if($conf =~ /code/)
		{
			$zip->extractTree('code/jlib',$JConfig::path_lib);
			$zip->extractMember('code/eml.cgi','eml.cgi');
			print 'Код воcстановлен.<br>';
		}
		
		unlink($tmpz);
		
		print '<br><br>Воcстановление закончено.';
	}
	elsif($sact eq 'send')
	{
		my $zfname = $r->{'fname'};
		CMS::fileman::path_it($zfname);
		
		JIO->clear();
		$JIO::headers{'Content-type'} = 'application/zip';
		$JIO::headers{'Content-Disposition'} = 'attachment; filename="'.$zfname.'"';
		
		my $fh;
		open($fh,'<',$JConfig::path_backup.'/'.$zfname);
		binmode($fh);
		binmode(select());
		print join('',<$fh>);
		close($fh);
		
		JIO->closeio();
	}
	else
	{
		print
		'
		<form action="?" method="post">
			<input type="hidden" name="url" value="',$o,'">
			<input type="hidden" name="act" value="cpanel_backup">
			<input type="hidden" name="sact" value="do">
			Выберите информацию, которую надо архивировать:<br><br>
			<table>
				<tr><td>Базу данных:</td><td><input type="checkbox" name="sql" checked></td></tr>
				<tr><td>Файлы пользователей:</td><td><input type="checkbox" name="ee" checked></td></tr>
				<tr><td>Служебные файлы:</td><td><input type="checkbox" name="etc" checked></td></tr>
				<tr><td colspan="2"><hr></td></tr>
				<tr><td>Дизайн:</td><td><input type="checkbox" name="www"></td></tr>
				<tr><td>Временные файлы:</td><td><input type="checkbox" name="tmp"></td></tr>
				<tr><td>Админка:</td><td><input type="checkbox" name="admin"></td></tr>
				<tr><td>Код:</td><td><input type="checkbox" name="code"></td></tr>
				<tr><td colspan="2"><hr></td></tr>
				<tr><td>Всё:</td><td><input type="checkbox" onclick="
					tc = this.checked;
					sql.checked=tc;
					ee.checked=tc;
					etc.checked=tc;
					www.checked=tc;
					tmp.checked=tc;
					admin.checked=tc;
					code.checked=tc;
				"></td></tr>
				<tr><td colspan="2"><hr></td></tr>
				<tr><td>Послать:</td><td><input type="checkbox" name="send" checked></td></tr>
				<tr><td></td><td>&nbsp;</td></tr>
				<tr><td colspan="2"><input type="submit" value="Архивировать"></td></tr>
			</table>
		</form>
		
		<form action="?" method="post" enctype="multipart/form-data">
			<input type="hidden" name="act" value="cpanel_backup">
			<input type="hidden" name="sact" value="upload">
			<input type="file" name="bfile">
			<input type="submit" value="Восстановить">
		</form>
		';
		
	}
}

sub install_code {}

1;