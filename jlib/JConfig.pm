# (с) Леонов П.А., 2005

# 
# Сборник переменных используемых различными модулями.
# Считаю его конфигурационным файлом.
# 

package JConfig;
use strict qw(subs vars);

sub init
{

# Пути HTTP

	our $http_eroot					= '/ee';
	our $http_wwfiles				= $http_eroot.'/wwfiles';
	our $http_errors				= $http_eroot.'/errors';
	our $http_userdocs				= $http_eroot.'/userdocs';
	our $http_aroot					= '/admin';


# Пути FS

	our $path_home					= '/home/engine';
	
	our $path_lib					= $path_home . '/jlib';
	our $path_etc					= $path_home . '/etc';
	our $path_tmp					= $path_home . '/tmp';
	our $path_htdocs				= $path_home . '/htdocs';
	our $path_backup				= $path_home . '/backup';
	our $path_sess					= $path_tmp . '/sessions';
	our $path_wwfiles				= $path_htdocs.$http_wwfiles;
	our $path_userdocs				= $path_htdocs.$http_userdocs;



# Разное

	our $debug						= 1;
	our $version					= '2.0.3.17'; #alpha
	our $print_timemeter			= 0;

# MySQL

	our $mysql_base					= 'engine';
	our $mysql_user					= 'root';
	our $mysql_pas					= 'pas';
	our $mysql_data_source			= 'DBI:mysql:'.$mysql_base;
	our $mysql_dumpcmd				= '/usr/mysql/bin/mysqldump -u'.$JConfig::mysql_user.' -p'.$JConfig::mysql_pas.' '.$JConfig::mysql_base;
	our $mysql_importcmd			= '/usr/mysql/bin/mysql -u'.$JConfig::mysql_user.' -p'.$JConfig::mysql_pas.' '.$JConfig::mysql_base;
	#our $mysql_charset				= 'cp1251';
	#our $mysql_colcon				= 'cp1251_general_ci';

# JDBI

	our $access_on					= 1;
	our $access_auto_off			= 1;
	our $users_login_list			= 1;
	our $users_pasoff				= 1;
	our $user_admin					= 1;
	our $user_guest					= 2;
	our $group_admin				= 1;
	our $group_guest				= 2;
	our $admin_max_view_name_len	= 50;
	our $admin_max_left				= 30;
	our $autosave					= 0;
	our $do_dbo_cache				= 1;
	our $lfnexrow_error505			= 0;
	our $array_def_on_page			= 20;
	
	our $access_on_e = $access_on;

# JIO

	our $buff_do					= 1;
	our $buff_mem					= 1;

# CMS

	our $have_left_frame			= 1;
	our $have_left_tree				= 1;

}

1;