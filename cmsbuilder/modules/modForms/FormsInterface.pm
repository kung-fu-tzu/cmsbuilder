# CMSBuilder © Леонов П. А., 2005-2006

package modForms::Interface;
use strict qw(subs vars);
use utf8;

#———————————————————————————————————————————————————————————————————————————————


#use CMSBuilder;
use CMSBuilder::Utils;
#use CMSBuilder::IO;

sub sview { return shift()->_sview(@_); }

sub forms_site_check
{
	my $o = shift;
	my $r = shift;
	
	my(@err,@ok);
	
	my $ps = $o->props();
	
	my $ck;
	for my $p ($o->sview())
	{
		$ck = $ps->{$p}->{'check'};
		if(ref $ck eq 'CODE')
		{
			if($ck->($r->{$p}))
			{
				push @ok, $p;
			}
			else
			{
				push @err, $p;
			}
		}
		elsif($ck)
		{
			if($r->{$p} =~ m/$ck/)
			{
				push @ok, $p;
			}
			else
			{
				push @err, $p;
			}
		}
		else
		{
			push @ok, $p;
		}
	}
	
	return {@ok?(-ok => [@ok]):(), @err?(-error => [@err]):()};
}

sub forms_site_page
{
	my $o = shift;
	my $r = shift;
	
	if($r->{'form-sub-act'} eq 'check')
	{
		my $res = $o->forms_site_check($r);
		
		print "<response>\n",(map {"<ok>$_</ok>\n"} @{$res->{-ok}}),(map {"<error>$_</error>\n"} @{$res->{-error}}),"</response>";
		
		return 1;
	}
	
	return;
}

sub forms_site_content
{
	my $o = shift;
	my $r = shift;
	
	if($o->access('w') && $r->{'form-act'})
	{
		if($r->{'form-act'} eq 'save')
		{
			my $res = $o->forms_site_check($r);
			if($res->{-error})
			{
				print '<div class="message">Ошибка заполнения формы.</div>';
			}
			else
			{
				$o->site_edit($r);
				$o->save();
				
				print '<div class="message">Данные успешно сохранены.</div>';
			}
		}
		
		if($r->{'form-act'} eq 'edit' || $r->{'form-act'} eq 'save')
		{
			print '<div class="message">Данные введены не полностью.</div>' unless $o->forms_site_valid();
			
			print
			'
			<div class="mod-forms">
			<form action="?" method="post" onsubmit="return modForms_check(this,\'',$o->site_href,'\')">
			<input type="hidden" name="form-act" value="save"/>
			';
			
			$o->site_props($r);
			
			print
			'
			<div class="submit"><button type="submit">Сохранить</button></div>
			</from>
			</div>
			';
			
			return 1;
		}
	}
	
	return;
}

sub forms_site_valid
{
	my $o = shift;
	
	return $o->forms_site_check($o)->{-error}?0:1;
}

sub site_props
{
	my $o = shift;
	my $r = shift;
	
	my $na =
	{
		-keys => [$o->sview()],
		@_
	};
	
	my $p = $o->props();
	
	unless( @{$na->{-keys}} ){ print '<div class="message">Нет доступных для редактирования свойств.</div>'; return 0; }
	
	print '<table>';
	
	my $vtype;
	for my $key (@{$na->{-keys}})
	{
		if($key eq '|'){ print '<tr><td colspan="2"><hr></td></tr>'; next; }
		
		$vtype = 'CMSBuilder::DBI::vtypes::'.$p->{$key}{'type'};
		if(${$vtype.'::admin_own_html'})
		{
			print $vtype->aview( $key, $o->{$key}, $o );
		}
		else
		{
			print
			'
			<tr>
			<th><label for="',$key,'">',$p->{$key}{'name'},'</label>:</th>
			<td>
			',$vtype->aview($key,$o->{$key},$o),'
			</td></tr>
			';
		}
	}
	
	print '</table>';
	
	return 1;
}

sub site_edit
{
	my $o = shift;
	my $r = shift;
	
	$o->admin_edit($r,-keys => [$o->_sview()]);
}


1;