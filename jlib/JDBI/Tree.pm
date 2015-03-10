# (�) ������ �.�., 2005

package JDBI::Tree;
use strict qw(subs vars);

###################################################################################################
# ������ ������ ������ � ������
###################################################################################################

sub name
{
	my $o = shift;
	my $ret;
	
	if($o->{'name'}){ return $o->{'name'} }
	unless($o->{'ID'}){ return '������ �� ������: '.$o->cname().' '.$o->{'ID'} }
	
	return $o->cname().' '.$o->{'ID'};
}

sub des_tree
{
	my $o = shift;
	
	my @all;
	my $count = 0;
	
	unshift(@all,$o->name());
	
	while($o = $o->papa() and $count < 50)
	{
		$count++;
		unshift(@all, $o->des_name());
	}
	
	print join(' :: ',@all);
}

sub des_page
{
	my $o = shift;
	
	print '<b>',$o->{'name'},'</b> ���������� ����� ��� ������ "',ref($o),'" �� ��������!';
}

sub des_title
{
	my $o = shift;
	return $o->name();
}

sub des_preview
{
	my $o = shift;
	
	print '<b>',$o->{'name'},'</b> ��������������� ����� ��� ������ "',ref($o),'" �� ��������!';
}

sub des_href
{
	my $o = shift;
	my $page = shift;
	
	return $o->page_ehtml().'/'.$o->myurl();
}

sub des_name
{
	my $o = shift;
	
	my $dname = $o->{'name'};
	if(!$dname){ $dname = $o->cname(); }
	
	return '<a href="'.$o->des_href().'">'.$dname.'</a>';
}


###################################################################################################
# �������������� ������
###################################################################################################

sub myurl
{
	my $o = shift;
	return ref($o).$o->{'ID'};
}

sub new
{
	my $c = shift;
	my $n = shift;
	
	my $o = {};
	bless($o,$c);
	
	$o->{'ID'} = $n;
	
	return $o;
}


###################################################################################################
# ������ �������� ������
###################################################################################################

sub err_add
{
	my $o = shift;
	my $errstr = shift;
	
	if(!$o->{'_errors'}){ $o->{'_errors'} = (); }
	
	push(@{ $o->{'_errors'} }, $errstr);
}

sub err_print
{
	my $o = shift;
	my $errstr;
	
	for $errstr ( @{ $o->{'_errors'} } ){ print $errstr,'<br>' }
}

sub err_is
{
	my $o = shift;
	
	return ($#{ $o->{'_errors'} } < 0) ? 0 : 1;
}







1;