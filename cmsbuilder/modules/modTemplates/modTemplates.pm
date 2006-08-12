# CMSBuilder © Леонов П. А., 2006

package modTemplates::modTemplates;
use strict qw(subs vars);
use utf8;

our @ISA = qw(modAdmin::Tree CMSBuilder::DBI::Array CMSBuilder::Module);

our $VERSION = 1.0.0.0;

sub _cname {'Шаблоны'}
sub _add_classes {qw(modTemplates::Dir)}
sub _aview {qw()}

sub _props
{
	'name'			=> { 'type' => 'string', 'length' => 25, 'name' => 'Название' },
}

#———————————————————————————————————————————————————————————————————————————————

use CMSBuilder::Utils;

sub install_code
{
	my $mod = shift;
	
	my $mr = modAdmin::modAdmin->root;
	
	my $to = $mod->cre();
	$to->{'name'} = $mod->cname();
	$to->save();
	
	$mr->elem_paste($to);
	
	my $td = modTemplates::Dir->cre();
	$td->{'name'} = 'Стандартные';
	$td->save();
	
	$to->elem_paste($td);
	
	my $tt = modTemplates::Template->cre();
	$tt->{'name'} = 'По умолчанию';
	$tt->{'content'} = f2var($CMSBuilder::Config::path_etc . '/first.tpl');
	$tt->save();
	
	$td->elem_paste($tt);
	
}

1;