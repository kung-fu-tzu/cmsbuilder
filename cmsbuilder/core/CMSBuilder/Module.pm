# CMSBuilder © Леонов П. А., 2005-2006

package CMSBuilder::Module;
use strict;
use utf8;

use CMSBuilder::SysUtils qw(VIRTUAL);

sub class_name {'Модуль ' . $_[0]}
sub admin_icon {0}

#———————————————————————————————————————————————————————————————————————————————

# Вызывается во время загрузки сервера
sub mod_load {VIRTUAL}

# Загружает конфиги модуля
sub mod_configure {VIRTUAL}

# Вызывается в начале обработки запроса
sub mod_init {VIRTUAL}

# Вызывается после того, как запрос обработан
sub mod_destruct {VIRTUAL}

# Вызывается перед завершением работы сервера
sub mod_unload {VIRTUAL}


1;