# (�) ������ �.�., 2005

package TemplateW;
use strict qw(subs vars);
our @ISA = 'Template';

sub _cname {'WYSIWYG-������ ��������'}

sub _props
{
	'content'	=> { 'type' => 'miniword', 'height' => '550px', 'full' => 1, 'name' => '��������' },
}

#-------------------------------------------------------------------------------


1;