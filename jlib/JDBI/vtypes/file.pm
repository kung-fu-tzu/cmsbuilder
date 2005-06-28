# (с) Леонов П.А., 2005

package JDBI::vtypes::file;
use strict qw(subs vars);
our @ISA = 'JDBI::VType';
import JDBI;
our $filter = 1;
our $dont_html_filter = 1;
# Содержимое файла и так не фильтруется - $val содержит имя файла.
# А данные читаются из потока.

# Любой файл ######################################################

sub table_cre
{
	return ' VARCHAR(10) ';
}

sub filter_load
{
	my $c = shift;
	return JDBI::vtypes::file::object->new(@_);
}

sub filter_save
{
	my $c = shift;
	return $_[1]->name(@_);
}

sub aview
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
	
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


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------


package JDBI::vtypes::file::object;
use strict qw(subs vars);

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
	
	unless($JDBI::group->{'files'})
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
		
		$fname = JDBI::translit($fname);
		$fname =~ s/\W/_/g;
		
		if( index( $p->{'ext'}, ' '.lc($ext).' ') < 0 and $p->{'ext'} ne '*' )
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
			
			if($len > ($p->{'msize'}*1024))
			{
				$obj->err_add('Файл слишком велик.');
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
	
	if($o->exists()){ $file_href = '<a target="_new" href="'.$o->href().'">Скачать...</a>'; }
	
	if($JDBI::group->{'files'})
	{
		if($o->exists()){ $file_del = 'Удалить - <input type=checkbox name="'.$o->{'_pname'}.'_todel">'; }
	}
	else
	{
		$not_perm = '\n\nЗапись файлов для Вашей группы не разрешена!';
		$block = 'disabled';
	}
	
	my @exts = split(/\s+/,$p->{'ext'});
	shift @exts;
	my $ext_list = join(', ', @exts);
	
	my $ret = '<input '.$block.' type="file" cols="30" name="'.$o->{'_pname'}.'">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.$file_del.'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'
		  .'<a href="#" onclick="alert(\'Допустимые расширения: '.$ext_list.'.\\nМаксимальный размер: '.$o->max_size_t().$not_perm .'\'); return false;">Справка...</a>&nbsp;&nbsp;&nbsp;'
		  .$file_href;
	
	return $ret;
}

sub name
{
	my $o = shift;
	return $o->{'_val'};
}

sub href
{
	my $o = shift;
	return $JConfig::http_wwfiles.'/'.$o->name();
}

sub path
{
	my $o = shift;
	return $JConfig::path_wwfiles.'/'.$o->name();
}

sub size
{
	my $o = shift;
	return (stat($o->path()))[7];
}

sub size_t
{
	my $o = shift;
	return JDBI::len2size( ( stat($o->path()) )[7] );
}

sub max_size
{
	my $o = shift;
	return $o->{'_prop'}->{'msize'}*1024;
}

sub max_size_t
{
	my $o = shift;
	return JDBI::len2size($o->max_size());
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
