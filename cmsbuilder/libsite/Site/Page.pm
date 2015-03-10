# (�) ������ �.�., 2006

package Page;
use strict qw(subs vars);
our @ISA = ('plgnSite::Member','CMSBuilder::DBI::Array');

sub _cname {'��������'}
sub _aview {qw/name content submenu/}
sub _have_icon {1}

sub _props
{
	'name'		=> { 'type' => 'string', 'length' => 100, 'name' => '��������' },
	'content'	=> { 'type' => 'miniword', 'name' => '�����' },
	'submenu'	=> { 'type' => 'select', 'variants' => [{'no'=>'�� ��������'},{'before'=>'�������� ����� �������'},{'after'=>'�������� ����� ������'},{'only'=>'�������� ��� ������'}], 'name' => '��������� ��������' },
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