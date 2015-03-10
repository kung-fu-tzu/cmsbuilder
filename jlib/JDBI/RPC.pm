# (�) ������ �.�., 2005

package JDBI::RPC;
use strict qw(subs vars);
use CGI ('param');

sub _rpcs {'default' => ['','']}

###################################################################################################
# ������ ���������� RPC
###################################################################################################

sub rpclist
{
	my $o = shift;
	my $buff = ref($o).'::_rpcs_buff';
	
	if($$buff){ return $$buff; }
	
	$$buff = {JDBI::Object::varr(ref($o),'_rpcs')};
	return $$buff;
}

sub rpc_exec
{
	my $o = shift;
	my $fn = shift;
	
	my $rpcf = $o->rpclist();
	
	unless($fn){ $o->err_add('������� ������ ��� �������.'); return; }
	unless($$rpcf{$fn}){ $o->err_add('������� <b>'.$fn.'</b> �� ��������� ��� RPC.'); return; }
	unless($o->can($fn)){ $o->err_add('������� <b>'.$fn.'</b> �� ����������.'); return; }
	
	return $o->$fn(@_);
}

1;