# (�) ������ �.�., 2005

package ModSysUtils;
use strict qw(subs vars);
our @ISA = 'JDBI::SimpleModule';

sub _cname {'��������� �������'}
# ����� ������ � ��������� ������. ������������, ��� �� ������ - ��� ������������� ���� ������
sub _classes {qw/ShortCut/}
sub _one_instance {1}

#-------------------------------------------------------------------------------


sub install_code {}

1;