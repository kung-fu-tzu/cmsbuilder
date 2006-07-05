# (с) Леонов П.А., 2005

package Template;
use strict qw(subs vars);
use utf8;

our @ISA = 'CMSBuilder::DBI::Object';

sub _cname {'Шаблон страницы'}
sub _aview {qw/name content/}

sub _props
{
	'name'		=> { 'type' => 'string', 'length' => 25, 'name' => 'Название' },
	'content'	=> { 'type' => 'html', 'height' => '550px', 'full' => 1, 'name' => 'Страница' },
}

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder;
use CMSBuilder::Utils;

sub parse
{
	my $o = shift;
	my $obj = shift;
	my $r = shift;
	
	my $cont = $o->{'content'};
	
	my $i;
	
	#while($cont =~ s#<div class="sms" name="(?:([\w\:]+)?\.)?(\w+)">(.*?)</div>#($1 || $obj)->template_call($1?($2,$obj):($2),$r,$3)#gse)
	#{
	#	last if($i++ > 50);
	#};
	
	while($cont =~ s/\${(\w+)}/$obj->template_call($1,$r)/ge)
	{
		last if($i++ > 50);
	};
	
	while($cont =~ s/\${(\S+)\.(\w+)}/$1->template_call($2,$r)/ge)
	{
		last if($i++ > 50);
	};
	
	while($cont =~ s/\${(\S+)\-\>(\w+)}/cmsb_url($1)->template_call($2,$r)/ge)
	{
		last if($i++ > 50);
	}
	
	return $cont;
}



1;