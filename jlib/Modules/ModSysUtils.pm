# (с) Леонов П.А., 2005

package ModSysUtils;
use strict qw(subs vars);
our @ISA = 'JDBI::SimpleModule';

sub _cname {'Системные Утилиты'}
# Смысл модуля в слудующей строке. Единственное, что он делает - это устанавливает свои классы
sub _classes {qw/ShortCut/}
sub _one_instance {1}

#-------------------------------------------------------------------------------


sub install_code {}

1;