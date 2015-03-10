# (�) �������� �. �., 2005-2006

package fbTheme;
use strict qw(subs vars);
our @ISA = ('plgnSite::Object','CMSBuilder::DBI::FilteredArray','CMSBuilder::DBI::Array');

sub _cname {'����'}
sub _aview {'name','desc','onpage'}
sub _add_classes {qw/fbQuestion/}
sub _have_icon {1}

sub _props
{
	'name'	=> { 'type' => 'string', 'length' => 100, 'name' => '��������' },
	'desc'	=> { 'type' => 'miniword', 'name' => '��������' }
}

#-------------------------------------------------------------------------------

use plgnUsers;
use CMSBuilder::Utils;

sub interval_filter
{
	my $o = shift;
	
	return @_ if !$o->papa() || $o->papa()->access('w');
	
	return grep {$_->{'answer'}} @_;
}

sub _have_icon 
{
	my $o = shift;
	
	return (grep {!$_->{'answer'}} $o->get_all())?'icons/fbTheme_new.gif':'icons/fbTheme.gif';
}

#-------------------------------------------------------------------------------
sub process_params
{
	my $o = shift;
	my $r = shift;
	
	return if $r->{'action'} ne 'save';
	
	if($r->{'question'}) #��� ������� - ������.
	{
		my $to = fbQuestion->cre();
		my $res = $o->elem_paste($to);
		
		$to->admin_edit($r);
		$to->save();
		
		print '<div class="message">';
		
		if($res)
		{
			my $href = $o->root->{'address'}.$CMSBuilder::Config::http_aroot;
			$href =~ s'/+'/'g;
			
			if($o->papa()->{'emailme'})
			{
				sendmail
				(
					'to'	=> $o->root->{'email'},
					'from'	=> $to->{'username'}.' <'.($to->{'email'} || $o->root->{'email'}).'>',
					'subj'	=> '������-�����, ����:'.$o->name(),
					'text'	=> $to->{'question'}."\n\n--\n\n����� ����� �������� �� �������: ".$href
				);
			}
			
			print
			'
			<p>�������, ��� ������ ��� ������� ��������. �� ������� ��� �� �����, ����� �� ����� ���������.</p>
			'.($to->{'emailme'}?'<p>�� ��������� ���� e-mail ����� ����������� �� ������.</p>':'').'
			<p><a href="'.$o->site_href().'?form=yes">���������� �������� �������...</a></p>
			';
		}
		else
		{
			print
			'
				� ���������, �� ����������� ��������, ��� ������ �� ��� ��������.
				���������� ��������� ��� �� �����: <a href="mailto:',$o->root->{'email'},'">',$o->root->{'email'},'</a>.
			';
			
			return 0;
		}
		
		print '</div>';
	}
	else
	{
		print '<div class="error">�� �� ����� ����� �������.</div>';
		return 0;
	}
	
	return 1;
}
#------------------------------------------------------------------------------------
#�������� ������� � �������� ������� �� ����� ����������� �������.
sub site_pagesline
{
	my $o = shift;
	my $r = shift;
	
	return if $r->{'form'};
	
	return $o->SUPER::site_pagesline($r,@_);
}
#------------------------------------------------------------------------------------
#������������� ������ ���. ���� �� ������� �����, ���� �� ��������.
sub site_content
{
	my $o = shift;
	my $r = shift;
	
	if($r->{'form'})
	{
		return if $o->process_params($r);
		return $o->print_form($r);
	}
	
	my @page = $o->get_page($r->{'page'});
	
	print '<div class="mod-feedback">';
	
	print $o->access('a') ? '<p><a href="?form=yes">������ ������...</a></p>' : '<p>���� �������.</p>';
	
	if(!@page)
	{
		print '<div class="message">� ���� ���� ��� ��������.</div>';
	}
	else
	{
		map { $_->site_preview() } @page;
	}
	
	print '</div>';
}
#-------------------------------------------------------------------------------
sub print_form
{
	my $o = shift;
	my $r = shift;
	
	print
	'
	<form action="?" method="post">
		<input type="hidden" name="action" value="save">
		<input type="hidden" name="form" value="yes">
		
		<table>
		<tr>
			<td><label for="username">���� ���</label>:</td>
			<td><input name="username" value="',$r->{'username'},'"></td>
		</tr>
		<tr>
			<td><label for="email">��� e-mail</label>:<br/><small>(��� ��������������)</small></td>
			<td><input name="email" value="',$r->{'email'},'"></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><input id="checkbox_emailme" type="checkbox" ',$r->{'emailme'}?'checked="checked"':'',' name="emailme"><label for="checkbox_emailme">���������� �� ������ �� e-mail</label></td>
		</tr>
		<tr>
			<td><label for="question">����� �������</label>:</td>
			<td><textarea cols="42" rows="15" name="question">',$r->{'question'},'</textarea></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><button type="submit">������ ������</button></td>
		</tr>
		</table>
	</form>
	';
}
#-------------------------------------------------------------------------------
sub site_preview
{
	my $o = shift;
	
	print
	'
		<div class="theme-rpeview">
			<div class="name">'.$o->site_aname().'</div>
			'.($o->{'descr'}?'<div class="desc">'.$o->{'desc'}.'</div>':'').'
		</div>
	';
}
#-------------------------------------------------------------------------------
1;