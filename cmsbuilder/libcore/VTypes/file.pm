# (с) Леонов П.А., 2005

package CMSBuilder::DBI::vtypes::file;
use strict qw(subs vars);

our @ISA = 'CMSBuilder::DBI::VType';
our $filter = 1;
our $dont_html_filter = 1;
# Содержимое файла и так не фильтруется - $val содержит имя файла.
# А данные читаются из потока.

# 'img'		=> { 'type' => 'file', 'msize' => 100, 'ext' => [qw/bmp jpg gif txt html/], 'name' => 'Картинка' },

# Любой файл ######################################################

sub table_cre
{
	return ' VARCHAR(50) ';
}

sub filter_load
{
	my $c = shift;
	return CMSBuilder::DBI::vtypes::file::object->new(@_);
}

sub filter_save
{
	my $c = shift;
	return $_[1]->name(@_);
}

sub aview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	unless($obj->{$name}){ $obj->{$name} = $c->filter_load(@_); }
	
	return $obj->{$name}->aview(@_);
}

sub aedit
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	unless($obj->{$name}){ $obj->{$name} = $c->filter_load(@_); }
	
	$obj->{$name}->aedit($name,$val,$obj,$r);
	return $obj->{$name};
}

sub del
{
	my $c = shift;
	$_[1]->del(@_);
}

sub copy
{
	my $c = shift;
	my ($name,$val,$obj,$nobj) = @_;
	
	return $val->copy(@_);
}


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------


package CMSBuilder::DBI::vtypes::file::object;
use strict qw(subs vars);

use CMSBuilder::Utils;
use plgnUsers;

sub new
{
	my $c = shift;
	
	my $o = {};
	bless($o,$c);
	
	$o->init(@_);
	
	return $o;
}

sub init
{
	my $o = shift;
	
	$o->{'_pname'} = shift;
	$o->{'_val'} = shift;
	$o->{'_obj'} = shift;
	
	unless($o->{'_obj'}){ return; }
	
	$o->{'_prop'} = $o->{'_obj'}->props()->{$o->{'_pname'}};
}

sub aedit
{
	my $o = shift;
	my $name = shift;
	my $val = CGI::param($name);shift();
	my $obj = shift;
	my $r = shift;
	
	unless($group->{'files'})
	{
		if($val){ $obj->err_add('Запись файлов для Вашей группы не разрешена.') }
		return $obj->{$name};
	}
	
	my $p = $o->{'_prop'};
	
	my ($buff,$len,$todel,$fh);
	
	if($val)
	{
		my ($fname,$ext);
		
		$fname = $val;
		$fname =~ s#\\#\/#g;
		$fname =~ s#.*\/##;
		$fname =~ m#^(.+)\.(\w+)$#;
		($fname,$ext) = ($1,$2);
		
		$fname = translit($fname);
		$fname =~ s/\W/_/g;
		
		$ext = lc($ext);
		
		if( indexA($ext,map {lc($_)} @{$p->{'ext'}}) < 0 and $p->{'ext'}->[0] ne '*' )
		{
			$obj->err_add('Расширение файла, '.$ext.', недопустимо.');
			return;
		}
		
		$o->del();
		
		my $num;
		do
		{
			$o->{'_val'} = $fname.$num.'.'.$ext;
			$num++;
		}
		while($o->exists());
		
		
		unless(open($fh,'>',$o->path()))
		{
			$obj->err_add('Невозможно открыть файл для записи: '.$o->path().'.');
			return;
		}
		
		binmode $fh;
		binmode $val;
		while(read($val,$buff,2048))
		{
			print $fh $buff;
			$len += 2048;
			
			if($len >= ($p->{'msize'}*1024))
			{
				$obj->err_add('Файл "'.$o->name().'" ('.$p->{'name'}.') слишком велик: более '.len2size($len).'.');
				return;
			}
		}
		close $fh;
		
		return;
	}
	else
	{
		if($r->{$name.'_todel'})
		{
			$o->del();
			return;
		}
	}
	
	return;
}

sub aview
{
	my $o = shift;
	
	my ($file_href,$file_del,$not_perm,$block);
	
	my $p = $o->{'_prop'};
	
	if($o->exists()){ $file_href = '<a href="'.$o->href().'">Просмотр...</a>'; }
	
	if($group->{'files'})
	{
		if($o->exists()){ $file_del = 'Удалить - <input type=checkbox name="'.$o->{'_pname'}.'_todel">'; }
	}
	else
	{
		$not_perm = '\n\nЗапись файлов для Вашей группы не разрешена!';
		$block = 'disabled';
	}
	
	my $ext_list = ($p->{'ext'}->[0] eq '*')?'без ограничений':join(', ', @{$p->{'ext'}});
	
	return
	'
	<input '.$block.' type="file" cols="30" name="'.$o->{'_pname'}.'">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.$file_del.'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="#" onclick="alert(\'Допустимые расширения: '.$ext_list.'.\\nМаксимальный размер: '.$o->max_size_t().$not_perm .'\'); return false;">Справка...</a>&nbsp;&nbsp;&nbsp;
	'.$file_href;
}

sub copy
{
	my $o = shift;
	my ($name,$val,$obj,$nobj) = @_;
	
	my $no = ref($o)->new($name,$o->{'_val'},$nobj);
	
	unless($o->exists()){ return $no; }
	
	$o->{'_val'} =~ m#^(.+)\.(\w+)$#;
	my ($fname,$ext) = ($1,$2);
	
	my $num;
	do
	{
		$no->{'_val'} = $fname.$num.'.'.$ext;
		$num++;
	}
	while($no->exists());
	
	my $fdata = f2var($o->path());
	var2f($fdata,$no->path());
	
	#print join(', ',%$no);
	return $no;
}

sub name
{
	my $o = shift;
	return $o->{'_val'};
}

sub href
{
	my $o = shift;
	return $CMSBuilder::Config::http_wwfiles.'/'.$o->name();
}

sub path
{
	my $o = shift;
	return $CMSBuilder::Config::path_wwfiles.'/'.$o->name();
}

sub size
{
	my $o = shift;
	return (stat($o->path()))[7];
}

sub size_t
{
	my $o = shift;
	return len2size( ( stat($o->path()) )[7] );
}

sub max_size
{
	my $o = shift;
	return $o->{'_prop'}->{'msize'}*1024;
}

sub max_size_t
{
	my $o = shift;
	return len2size($o->max_size());
}

sub del
{
	my $o = shift;
	unlink($o->path());
	$o->{'_val'} = '';
}

sub exists
{
	my $o = shift;
	return -f $o->path();
}

1;
