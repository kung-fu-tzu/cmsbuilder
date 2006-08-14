# CMSBuilder © Леонов П. А., 2005-2006

package modTemplates::TemplateW;
use strict qw(subs vars);
use utf8;

our @ISA = 'modTemplates::Template';

sub _cname {'WYSIWYG-шаблон страницы'}

sub _props
{
	content	=> { type => 'miniword', height => '550px', full => 1, name => 'Страница' },
}

#———————————————————————————————————————————————————————————————————————————————


1;