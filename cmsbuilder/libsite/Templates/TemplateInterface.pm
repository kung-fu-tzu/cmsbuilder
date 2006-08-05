# (с) Леонов П.А., 2006

package modTemplates::Interface;
use strict qw(subs vars);
use utf8;

sub _template_export {}

#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder;
use CMSBuilder::Utils;

sub template_call
{
	my $o = shift;
	my $val = shift;
	my @arg = @_;
	
	if(indexA($val,$o->template_export()) >= 0)
	{
		return catch_out { eval { $o->$val(@arg) }; $@?print($@):0; };
	}
	else
	{
		return "[метод шаблона $val не поддерживается]";
	}
}

sub template_export
{
	my $c = ref($_[0]) || $_[0];
	my $buff = $c.'::_template_export_buff';
	
	if($$buff){ return @$$buff; }
	
	my @t = varr($c,'_template_export',1);
	
	my @res;
	for my $v (reverse @t)
	{
		if($v eq '-'){ last; }
		unshift(@res,$v)
	}
	
	my $h = {};
	@res = grep {$h->{$_}?0:($h->{$_} = 1); } @res;
	
	$$buff = [@res];
	return @$$buff;
}

1;