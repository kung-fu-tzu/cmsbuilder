# CMSBuilder © Леонов П. А., 2005-2006

package modAccess::modAccess;
use strict qw(subs vars);
use utf8;

use CMSBuilder;

use Exporter;
our @EXPORT =
qw(
	$AC_READ $AC_WRITE $AC_ADD $AC_CHMOD $AC_CHOWN
	%access_types %access_type2bin
);

our ($AC_READ,$AC_WRITE,$AC_ADD,$AC_CHMOD,,$AC_CHOWN) = (1,2,4,8,16,32);

our %access_types =
(
	$AC_READ => 'Чтение',
	$AC_WRITE => 'Редактирование',
	$AC_ADD => 'Добавление&nbsp;элементов',
	$AC_CHMOD => 'Смена&nbsp;разрешений',
	#$AC_EXEC => 'Доступ&nbsp;ко&nbsp;вложенным',
	$AC_CHOWN => 'Изменять&nbsp;владельца',
);

our %access_type2bin =
(
	'r' => $AC_READ,
	'w' => $AC_WRITE,
	'a' => $AC_ADD,
	'c' => $AC_CHMOD,
	#'x' => $AC_EXEC,
	'o' => $AC_CHOWN,
);

our @ISA = qw(CMSBuilder::Module Exporter);
sub _cname {'Разделение доступа'}

sub mod_load
{
	unshift @CMSBuilder::DBI::Object::ISA,'modAccess::Object';
	
	cmsb_event_reg('admin_view_additional',\&admin_additional);
}

sub admin_additional
{
	my $o = shift;
	
	print '<tr><td valign="top">Вам&nbsp;разрешено:</td><td valign="top">',$o->access_print(),'</td></tr>';
}

1;