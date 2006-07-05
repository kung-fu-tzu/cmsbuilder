# (с) Леонов П.А., 2005

package TemplateW;
use strict qw(subs vars);
use utf8;

our @ISA = 'Template';

sub _cname {'WYSIWYG-шаблон страницы'}

sub _props
{
	'content'	=> { 'type' => 'miniword', 'height' => '550px', 'full' => 1, 'name' => 'Страница' },
}

#———————————————————————————————————————————————————————————————————————————————


1;