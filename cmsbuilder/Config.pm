# CMSBuilder © Леонов П. А., 2005-2006

# Глобальный конфигурационный файл билдера.

package CMSBuilder::Config;
use strict qw(subs vars);
use utf8;

our $path_home;

BEGIN { $path_home = '/home/cmsbuilder3'; }

use lib $path_home . '/cmsbuilder/libperl';
#use lib $path_home . '/cmsbuilder/libperl/arch/freebsd4'; #FreeBSD 4.10-RELESE

use lib $path_home . '/cmsbuilder/core';
use lib $path_home . '/cmsbuilder/modules';


sub init
{

# Пути HTTP

	our $http_eroot					= '/ee';
	our $http_wwfiles				= $http_eroot . '/wwfiles';
	our $http_errors				= $http_eroot . '/errors';
	our $http_userdocs				= $http_eroot . '/userdocs';
	our $http_aroot					= '/admin';
	our $http_adress				= 'http://' . $ENV{'SERVER_NAME'};


# Пути FS

	our $path_cmsb					= $path_home.'/cmsbuilder';
	
	our $path_core					= $path_cmsb . '/core';
	our $path_modules				= $path_cmsb . '/modules';
	our $path_etc					= $path_cmsb . '/etc';
	our $path_tmp					= $path_cmsb . '/tmp';
	our $path_backup				= $path_cmsb . '/backup';
	our $path_sess					= $path_tmp . '/sessions';
	
	our $path_htdocs				= $path_home . '/htdocs';
	our $path_aroot					= $path_htdocs . $http_aroot;
	our $path_wwfiles				= $path_htdocs . $http_wwfiles;
	our $path_userdocs				= $path_htdocs . $http_userdocs;


# Файлы

	our $file_errorlog				= $path_etc . '/error.log';


# Сервер

	#our $server_type				= 'cgi-server';
	our $server_addres				= 'local:' . $path_etc . '/cgi_server_socket'; # 'tcp:127.0.0.1:9079';
	our $server_cmd_start			= $path_home . '/cgi-bin/cmsb.pl server';
	our $server_pidfile				= $path_etc . '/server_pid';
	our $server_autostart			= 1;
	our $server_daemon				= 1;
	our $server_shdown				= 50;


# MySQL

	our $mysql_base					= 'cmsbuilder3';
	our $mysql_user					= 'root';
	our $mysql_pas					= 'pas';
	our $mysql_host					= 'localhost';
	our $mysql_port					= 3306;
	our $mysql_data_source			= "DBI:mysql:$mysql_base;host=$mysql_host;port=$mysql_port";
	our $mysql_dumpcmd				= "/usr/local/bin/mysqldump -u $mysql_user -p$mysql_pas -P $mysql_port -h $mysql_host -Q --compatible=mysql40 --add-drop-table $mysql_base";
	our $mysql_importcmd			=     "/usr/local/bin/mysql -u $mysql_user -p$mysql_pas -P $mysql_port $mysql_base";
	our $mysql_charset				= 'utf8'; # cp1251
	our $mysql_colcon				= 'utf8_general_ci'; # cp1251_general_ci


# CMSBuilder::DBI

	our $access_on					= 1;
	our $access_auto_off			= 1;
	our $users_login_list			= 1;
	our $users_pasoff				= 1;
	our $user_admin					= 'modUsers::User1';
	our $user_guest					= 'modUsers::User3';
	our $admin_max_view_name_len	= 25;
	our $admin_max_left				= 30;
	our $autosave					= 0;
	our $do_dbo_cache				= 1;
	our $lfnexrow_error500			= 0;
	our $array_def_on_page			= 20;
	our $dbi_inactivedestroy		= 0;
	our $dbi_keepalive				= 1;
	our $table_name_pfx 			= '';
	
	our $access_on_e = $access_on;


# CMSBuilder

	our @io_filters					= qw//; #fltXSLT fltGZIP
	our @process_classes			= qw/CMSBuilder::MYURL CMSBuilder::EML/;
	our $redirect_status			= '200';
	our $slashobj_myurl				= 'modSite::modSite1';


# CMS

	our $have_left_frame			= 1;
	our $have_left_tree				= 1;
	our $admin_left_width			= 280;

}

init();

1;