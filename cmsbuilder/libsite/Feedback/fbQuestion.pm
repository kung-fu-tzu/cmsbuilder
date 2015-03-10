# (�) �������� �. �., 2006

package fbQuestion;
use strict qw(subs vars);
our @ISA = ('plgnSite::Object','CMSBuilder::DBI::Object');

sub _cname {'������'}
sub _aview {qw/username email emailme question answer emailed/}

sub _props
{
	'username'		=> { 'type' => 'string', 'length' => 20, 'name' => '��� ������������'},
	'email'			=> { 'type' => 'string', 'length' => 50, 'name' => 'e-mail' },
	'emailme'		=> { 'type' => 'checkbox', 'name' => '�������� �� ������ �� e-mail' },
	'emailed'		=> { 'type' => 'checkbox', 'name' => '����������� ����������' },
	'question'		=> { 'type' => 'text', 'name' => '��� ������' },
	'answer'		=> { 'type' => 'text', 'name' => '�����' }
}

#-------------------------------------------------------------------------------


use CMSBuilder::Utils;
use CMSBuilder::IO::Session;

sub _have_icon 
{
	my $o = shift;
	
	return $o->{'answer'}?'icons/fb_quest.gif':'icons/fb_quest_new.gif';
}

sub name
{
	my $o = shift;
	return substr($o->{'question'},0,25).(length($o->{'question'})>25?'...':'');
}

sub site_head {}

sub admin_edit
{
	my $o = shift;
	my $r = shift;
	
	my $res = $o->SUPER::admin_edit($r,@_);
	
	if($o->{'emailme'} && $o->{'email'} && $o->{'answer'} && !$o->{'emailed'})
	{
		my $question = $o->{'question'};
		$question =~ s/^/\> /g;
		
		my $href = $o->root->{'address'}.$o->site_href();
		$href =~ s'/+'/'g;
		
		my $sended = sendmail
		(
			'to'	=> $o->{'email'},
			'from'	=> $o->root->{'email'},
			'subj'	=> 'Re: '.$o->papa()->name(),
			'text'	=> $question."\n\n".$o->{'answer'}."\n\n--\n\n��������: ".$href
		);
		
		if($sended)
		{
			$o->notice_add('������������ ���������� �����������.');
			$o->{'emailed'} = 1;
		}
		else
		{
			$o->err_add('������ �������� �����������.');
		}
	}
	
	$sess->{'admin_refresh_left'} = 1;
	
	return $res;
}
#-------------------------------------------------------------------------------
sub site_preview
{
	my $o = shift;
	
	print
	'
		<div class="mod-feedback-question">
			<div class="question">
				<div class="head">������'.($o->{'username'}?' �� ������������ &laquo;'.$o->{'username'}.'&raquo;':'').': </div>
				<div class="text">'.$o->{'question'}.'</div>
			</div>
			<div class="answer">
				<div class="head">�����: </div>
				<div class="text">'.$o->{'answer'}.'</div>
			</div>
		</div>
	';
}
#-------------------------------------------------------------------------------
sub site_content
{
	my $o = shift;
	return $o->site_preview(@_);
}
#-------------------------------------------------------------------------------
1;