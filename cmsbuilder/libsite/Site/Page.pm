# (с) Леонов П.А., 2006

package Page;
use strict qw(subs vars);
our @ISA = ('plgnSite::Member','CMSBuilder::DBI::Array');

sub _cname {'Страница'}
sub _aview {qw/name content submenu/}
sub _have_icon {1}

sub _props
{
	'name'		=> { 'type' => 'string', 'length' => 100, 'name' => 'Название' },
	'content'	=> { 'type' => 'miniword', 'name' => 'Текст' },
	'submenu'	=> { 'type' => 'select', 'variants' => [{'no'=>'не выводить'},{'before'=>'выводить перед текстом'},{'after'=>'выводить после текста'},{'only'=>'выводить без текста'}], 'name' => 'Вложенные страницы' },
}

#-------------------------------------------------------------------------------


sub site_content
{
	my $o = shift;
	my $r = shift;
	
	if($o->{'submenu'} eq 'only')
	{
		$o->site_submenu($r);
	}
	elsif($o->{'submenu'} eq 'after')
	{
		print $o->{'content'};
		$o->site_submenu($r);
	}
	elsif($o->{'submenu'} eq 'before')
	{
		$o->site_submenu($r);
		print $o->{'content'};
	}
	else
	{
		print $o->{'content'};
	}
}

1;