# (�) ������ �.�., 2005

package ModControlPanel;
use strict qw(subs vars);
our @ISA = 'JDBI::SimpleModule';

sub _cname {'������ ����������'}
sub _icon {1}
sub _one_instance {1}

sub _rpcs
{
	'cpanel_table_cre'		=> ['',''],
	'cpanel_table_fix'		=> ['�������� ���������...','table.gif'],
	'cpanel_object_stat'	=> ['���������� ��������','install.gif'],
	'cpanel_install_mods'	=> ['��������� ������...','install.gif'],
	'cpanel_backup'			=> ['��������� �����','backup.gif'],
	'cpanel_mod_root'		=> ['������ �������','ModRoot.gif'],
	#'cpanel_scanbase'		=> ['��������� ����...','install.gif'],
	''	=> [],
	''	=> [],
}

our	$refresh;

sub default
{
	print '������ "������ ����������" �������� ��� �������������� ����������� ������� � �������� ��������� ����������.';
}

sub admin_view_left
{
	my $o = shift;
	
	unless(ModRoot->table_have())
	{
		print '<br><center>��������� ���� �� �����������!</center>';
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
		print '<br><br>��������� ���� �� �����������! <a href="?url=',$o->myurl(),'&act=cpanel_table_cre"><b>����������...</b></a>';
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
	$mr->{'name'} = '������ �������';
	$mr->save();
	
	print '������� ���� �������, ������� ���������� � ������ ������� ������� �����������.<br><br>';
	
	for my $mod (@JDBI::modules){ $mod->mod_table_cre() }
}

sub cpanel_table_fix
{
	my $ch;
	for my $mod (@JDBI::modules){ $ch |= $mod->mod_table_fix(); }
	
	print '<br>';
	if($ch){ print '��������� ���������.'; }
	else{ print '���������� �� ���������.'; }
}

sub cpanel_object_stat
{
	print '<br><table><tr><td align="center"><b>�����</b></td><td width="25">&nbsp;</td><td><b>���-��</b></td></tr>';
	
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
	
	if($some){ print '<br>������ ������� �����������.'; $refresh = 1; }
	else{ print '<br>��������� �� ���������.'; }
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
			print '<br>����� ������� ������: <b>'.$zfname.'</b> ('.JDBI::len2size((stat($JConfig::path_backup.'/'.$zfname))[7]).').';
			if($r->{'send'}){ print '<iframe height="0" width="0" src="?act=backup&sact=send&fname=',$zfname,'"></iframe>'; }
		}
		else{ print '�� ������� ��������� ���� ������!'; }
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
		
		unless($zip->memberNamed($confname)){ print '�������� ������ �����!<br>'; return; }
		
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
			print '������ ���c��������.<br>';
		}
		
		if($conf =~ /ee/)
		{
			$zip->extractTree('ee',$JConfig::path_htdocs.$JConfig::http_eroot);
			print '����� ������������� ���c���������.<br>';
		}
		
		if($conf =~ /admin/)
		{
			$zip->extractTree('admin',$JConfig::path_htdocs.$JConfig::http_aroot);
			print '������� ���c���������.<br>';
		}
		
		if($conf =~ /etc/)
		{
			$zip->extractTree('etc',$JConfig::path_etc);
			print '��������� ����� ���c���������.<br>';
		}
		
		if($conf =~ /tmp/)
		{
			$zip->extractTree('tmp',$JConfig::path_tmp);
			print '��������� ����� ��c����������.<br>';
		}
		
		if($conf =~ /code/)
		{
			$zip->extractTree('code/jlib',$JConfig::path_lib);
			$zip->extractMember('code/eml.cgi','eml.cgi');
			print '��� ��c���������.<br>';
		}
		
		unlink($tmpz);
		
		print '<br><br>��c����������� ���������.';
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
			�������� ����������, ������� ���� ������������:<br><br>
			<table>
				<tr><td>���� ������:</td><td><input type="checkbox" name="sql" checked></td></tr>
				<tr><td>����� �������������:</td><td><input type="checkbox" name="ee" checked></td></tr>
				<tr><td>��������� �����:</td><td><input type="checkbox" name="etc" checked></td></tr>
				<tr><td colspan="2"><hr></td></tr>
				<tr><td>������:</td><td><input type="checkbox" name="www"></td></tr>
				<tr><td>��������� �����:</td><td><input type="checkbox" name="tmp"></td></tr>
				<tr><td>�������:</td><td><input type="checkbox" name="admin"></td></tr>
				<tr><td>���:</td><td><input type="checkbox" name="code"></td></tr>
				<tr><td colspan="2"><hr></td></tr>
				<tr><td>��:</td><td><input type="checkbox" onclick="
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
				<tr><td>�������:</td><td><input type="checkbox" name="send" checked></td></tr>
				<tr><td></td><td>&nbsp;</td></tr>
				<tr><td colspan="2"><input type="submit" value="������������"></td></tr>
			</table>
		</form>
		
		<form action="?" method="post" enctype="multipart/form-data">
			<input type="hidden" name="act" value="cpanel_backup">
			<input type="hidden" name="sact" value="upload">
			<input type="file" name="bfile">
			<input type="submit" value="������������">
		</form>
		';
		
	}
}

sub install_code {}

1;