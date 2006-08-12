# (с) Леонов П.А., 2005

package CMSBuilder::Module;
use strict qw(subs vars);
use utf8;

sub _cname {'Модуль ' . $_[0]}
sub _have_icon {0}

#———————————————————————————————————————————————————————————————————————————————

# Вызывается во время загрузки сервера
sub mod_load {}

# Вызывается в начале обработки запроса
sub mod_init {}

# Вызывается после того, как запроса обработан
sub mod_destruct {}

# Вызывается перед завершением работы сервера
sub mod_unload {}


sub mod_install {}

sub cname { $_[0]->_cname }

1;