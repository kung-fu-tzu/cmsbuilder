# 
# Сборник переменных используемых различными модулями.
# 

package JConfig;
use strict qw(subs vars);

###################################################################################################
# Global
###################################################################################################

# Пути

our $path_home      = '/home/engine';


our $path_lib       = $path_home . '/jlib';
#our $path_etc       = $path_home . '/etc';
our $path_tmp       = $path_home . '/tmp';
our $path_htdocs    = $path_home . '/htdocs';

our $http_wwfiles   = '/wwfiles';
our $path_wwfiles   = $path_htdocs.$http_wwfiles;

our $path_sess      = $path_tmp . '/sessions';

# Global

our $debug = 1;

# MySQL

our $mysql_base     = 'DBI:mysql:engine';
our $mysql_user     = 'root';
our $mysql_pas      = 'pas';

# JDBI

our $users_do       = 0;
our $admin_max_left_name_len = 50;
our $admin_max_left = 20;

# JIO

our $buff_do        = 1;
our $buff_mem       = 1;



return 1;






