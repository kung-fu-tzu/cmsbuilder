# 
# Сборник переменных используемых различными модулями.
# 

package JConfig;
use strict qw(subs vars);

sub init
{

# Пути

our $path_home      = '/home/engine';


our $path_lib       = $path_home . '/jlib';
our $path_etc       = $path_home . '/etc';
our $path_tmp       = $path_home . '/tmp';
our $path_htdocs    = $path_home . '/htdocs';

our $http_eroot      = '/ee';
our $http_wwfiles   = $http_eroot.'/wwfiles';
our $http_errors    = $http_eroot.'/errors';
our $path_wwfiles   = $path_htdocs.$http_wwfiles;

our $path_sess      = $path_tmp . '/sessions';

# Разное

our $debug = 1;
our $version = 2.0;
our $print_timemeter = 1;

# MySQL

our $mysql_base     = 'DBI:mysql:engine';
our $mysql_user     = 'root';
our $mysql_pas      = 'pas';

# JDBI

our $users_do                   = 0;
our $users_login_list           = 1;
our $users_pasoff               = 1;
our $user_admin                 = '1';
our $user_guest                 = '2';
our $group_admin                = '1';
our $group_guest                = '2';
our $admin_max_left_name_len    = 50;
our $admin_max_left             = 30;
our $autosave                   = 1;
our $do_dbo_cache               = 1;
our $array_def_on_page          = 20;

# JIO

our $buff_do        = 1;
our $buff_mem       = 1;

# CMS

our $have_left_frame = 1;
our $have_left_tree  = 1;

}

return 1;