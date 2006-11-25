# CMSBuilder © Леонов П. А., 2005-2006

# Конфигурационный файл билдера
# (перекрывает значения из Config.pm)

package CMSBuilder::Config;
use strict;
use utf8;

# Обявляем, чтобы скомпилировалось,
# а определяем здесь, или можем еще раньше — в загрузчике
our $path_home;

BEGIN
{
	# если путь задан ранее, например в cmsb.pl,
	# то след. строка должна быть закомментирована
	#$path_home = '/home/cmsbuilder';
}

use lib $path_home . '/cmsbuilder/perl';
# бинарники для FreeBSD 4
#use lib $path_home . '/cmsbuilder/perl/arch/freebsd4'; #FreeBSD 4.10-RELESE
use lib $path_home . '/cmsbuilder/core';


# MySQL

our $mysql_base					= 'cmsbuilder3';
our $mysql_user					= 'root';
our $mysql_pas					= 'pas';
#our $mysql_host					= 'localhost';
#our $mysql_port					= 3306;


#———————————————————————————————————————————————————————————————————————————————

# загружаем конфиг по умолчанию
require CMSBuilder::Config;

#———————————————————————————————————————————————————————————————————————————————


# Сервер

our $server_type				= 'self-test';
#our $server_type				= 'cgi';
#our $server_shdown				= 50;

# Файлы

our $file_errorlog				= undef;

# DB

our $db_default_account			= $CMSBuilder::Config::db_mysql_account;
our $db_default_class			= $CMSBuilder::Config::db_mysql_class; #'CMSBuilder::DB'


# CMSBuilder::DB

our $access_on					= 0;
#our $access_auto_off			= 1;
#our $users_login_list			= 1;
#our $users_pasoff				= 1;

our $db_connections =
{
	mysql1		=> {class => 'modDBI::MySQL', account => $CMSBuilder::Config::db_mysql_account},
	sdbm1		=> {class => 'modDBI::SDBM', file => 'sdbm1.db'},
	default		=> {class => 'CMSBuilder::DBDefault'}
};

our $access_on_e = $access_on;


# CMSBuilder

our @io_filters					= qw(); #fltXSLT fltGZIP
our $slashobj_url				= 'modSite::modSite1';
our @modules_load_order			= qw(modDBI::MySQL *);

#$^W = 1;

1;