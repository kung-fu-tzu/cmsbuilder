#!/usr/bin/perl
use strict;
use utf8;

use Test::Simple tests => 45;

use CMSBuilder;

### у cmsb_rpc должно быть как минимум два параметра
eval "cmsb_rpc()"; ok $@, 'cmsb_rpc($)';



#———————————————————————————————————————————————————————————————————————————————



### обявим функции для теста
sub Test::func1 {return @_}

### у cmsb_hook должно быть ровно два параметра
ok $@, 'cmsb_hook($$)';
eval "cmsb_hook(1,1,1)"; ok $@, 'cmsb_hook($$)';

### второй аргумент должен быть ссылкой на код
eval { cmsb_hook('Test::func1',123) }; ok $@, 'cmsb_hook($,CODEref)';
eval { cmsb_hook('Test::func1',{}) }; ok $@, 'cmsb_hook($,CODEref)';
eval { cmsb_hook('Test::func1',[]) }; ok $@, 'cmsb_hook($,CODEref)';
### первый аргумент должен быть именем существующей функции
eval { cmsb_hook('Test::not_existed_func', sub {}) }; ok $@, 'cmsb_hook(existed_func,$)';

### все должно работать для правильных параметров
ok cmsb_hook('Test::func1', sub {$_ = shift; $_->(@_)}), 'cmsb_hook(existed_func,CODEref)';
### как обычно, проверим передачу и возвращение параметров
ok join('',Test::func1('OK',1,2,3,'OK')) eq 'OK123OK', 'cmsb_hook breaks params';

### у cmsb_hookp должно быть ровно два параметра
eval "cmsb_hookp(1)"; ok $@, 'cmsb_hookp($$)';
eval "cmsb_hookp(1,1,1)"; ok $@, 'cmsb_hookp($$)';

### создадим функции в пакетах для теста
sub Test::a::func1 {}
sub Test::a::func2 {}
sub Test::b::func1 {}
sub Test::b::func2 {}
sub Test::c::func1 {}

### оба параметра должны быть уже созданными в дереве данных пакетами
eval { cmsb_hookp('Test::not_existed','Test::c') }; ok $@, 'cmsb_hookp(existed_package,existed_package)';
eval { cmsb_hookp('Test::c','Test::not_existed') }; ok $@, 'cmsb_hookp(existed_package,existed_package)';

### хуканем с нормальными параметрами — двумя сущ. пакетами
ok cmsb_hookp('Test::a','Test::b'), 'cmsb_hookp(existed_package,existed_package)';



#———————————————————————————————————————————————————————————————————————————————



### подготовим цепочку классов
sub Test::varr::a::samovar {'a'}
@Test::varr::a::ISA = qw(Test::varr::b);
sub Test::varr::b::samovar {'b'}
@Test::varr::b::ISA = qw(Test::varr::c1 Test::varr::c2);
sub Test::varr::c1::samovar {'c1'}
sub Test::varr::c2::samovar {'c2'}

sub Test::varr::t1::samovar {'1'}
@Test::varr::t1::ISA = qw(Test::varr::t2);
sub Test::varr::t2::samovar {'2','3','4'}

sub Test::varr::ref::some_var {{var => 'val'}}


### cmsb_varr() принимает два обязательных параметра и один необязательный
eval "cmsb_varr(1)"; ok $@, 'cmsb_varr($)';
eval "cmsb_varr(1,1,1,1); 1"; ok $@, 'cmsb_varr can four parameters';

### проверим прямой порядок сбора значений
ok join('', cmsb_varr('Test::varr::a','samovar')) eq 'abc1c2', 'cmsb_varr forward1';
ok join('', cmsb_varr('Test::varr::a','samovar',1)) eq 'abc1c2', 'cmsb_varr forward2';
ok join('', cmsb_varr('Test::varr::t1','samovar')) eq '1234', 'cmsb_varr forward_pair';
### и обратный
#warn join('', cmsb_varr('Test::varr::a','samovar',0));
ok join('', cmsb_varr('Test::varr::a','samovar',0)) eq 'c2c1ba', 'cmsb_varr backward';
ok join('', cmsb_varr('Test::varr::t1','samovar',0)) eq '2341', 'cmsb_varr backward_pair';



### проверим, работает ли ограничитель рекурсии
ok ! CMSBuilder::_cmsb_varr('Test::varr::a','samovar',1,51), 'recursion';

### возвращает ли структуры правильно
ok ((cmsb_varr('Test::varr::ref','some_var'))[0]->{'var'} eq 'val', 'varr_ref');



#———————————————————————————————————————————————————————————————————————————————



### cmsb_event_ro должен возвращать простой екземпляр CMSBuilder::Object
ok ref cmsb_event_ro() eq 'CMSBuilder::Object', 'cmsb_event_ro would be of CMSBuilder::Object class';
ok ! %{cmsb_event_ro()}, 'cmsb_event_ro would be empty';



#———————————————————————————————————————————————————————————————————————————————



### подготовим пару простых слассов и пару модулей
@Test::regpm::a::ISA = 'CMSBuilder::Object';
@Test::regpm::b::ISA = 'CMSBuilder::Object';
@Test::regpm::c::ISA = 'CMSBuilder::Module';
@Test::regpm::d::ISA = 'CMSBuilder::Module';
@Test::regpm::e::ISA = qw(CMSBuilder::Object CMSBuilder::Module);
sub Test::regpm::e::load {'OK'}
sub Test::regpm::notreged::load {'OK'}

### cmsb_regpm должна возвращать ложь, если хоть один из пакетов не зарегался
ok ! cmsb_regpm('aaa','bbb','ccc'), 'cmsb_regpm couldn`t reg simple classes';
### а так же должна выставить в ошибку строку с перечислнием незареганых пакетов
ok ! $cmsb_error !~ /aaa, bbb, ccc/, 'checking $cmsb_error after cmsb_regpm(): ' . $cmsb_error;
### а тут все должно пройти успешно: принадлежность всех пакетов можно определить
ok cmsb_regpm( qw(Test::regpm::a Test::regpm::b Test::regpm::c Test::regpm::d Test::regpm::e)), 'work cmsb_regpm() with good packeges';
### ну и проверим, появились ли имена классов в соотв. списках
ok join(' ', @CMSBuilder::classes) eq 'Test::regpm::a Test::regpm::b Test::regpm::e', '@CMSBuilder::classes';
ok join(' ', @CMSBuilder::modules) eq 'Test::regpm::c Test::regpm::d Test::regpm::e', '@CMSBuilder::modules';
### и функции
ok join(' ', @CMSBuilder::classes) eq join(' ', cmsb_classes()), 'cmsb_classes()';
ok join(' ', @CMSBuilder::modules) eq join(' ', cmsb_modules()), 'cmsb_modules()';

### подстрахуем проверку классов
ok cmsb_classOK('Test::regpm::a') && cmsb_classOK('Test::regpm::b') && cmsb_classOK('Test::regpm::e'), 'cmsb_classOK()';
ok ! cmsb_classOK('Test::regpm::not_existed');
ok ! cmsb_classOK('Test::regpm::notreged');



#———————————————————————————————————————————————————————————————————————————————



### проверим расклад урлов и классов
ok join('+', cmsb_url2classid('Test::foo456')) eq 'Test::foo+456', 'cmsb_url2classid';
ok join('+', cmsb_url2classid('Class456')) eq 'Class+456', 'cmsb_url2classid';
ok cmsb_url('Test::regpm::e1') eq 'OK', 'cmsb_url';
ok ! cmsb_url('Test::regpm::not_existed'), 'cmsb_url';


### проверим угадывалку имени класса
ok cmsb_class_guess('Test::reGpm::A') eq 'Test::regpm::a', 'cmsb_class_guess';
#warn cmsb_class_guess('Test::regpm::not_existed');
ok ! cmsb_class_guess('Test::regpm::not_existed'), 'cmsb_class_guess: not_existed';

# cmsb_modload



#———————————————————————————————————————————————————————————————————————————————



### правильно ли работает проверка редирект-статуса
$CMSBuilder::Config::cfg->{cgi}->{redirect_status} = 333;
eval { CMSBuilder::check_redirect() }; ok $@, 'REDIRECT_STATUS';
$ENV{'REDIRECT_STATUS'} = 333;
eval { CMSBuilder::check_redirect() }; ok !$@, 'REDIRECT_STATUS';
undef $CMSBuilder::Config::cfg->{cgi}->{redirect_status};
eval { CMSBuilder::check_redirect() }; ok !$@, 'REDIRECT_STATUS';

### сделаем одновременно и классы и функции для теста обработки запросов
sub Test::process1::process_request { die unless $_[0] eq 'Test::process1' && ref $_[1] eq 'HASH' }
sub Test::process2::process_request { die unless $_[0] eq 'Test::process2' && ref $_[1] eq 'HASH' }

### передает ли запрос
$CMSBuilder::Config::cfg->{server}->{process_classes} = [qw(Test::process1 Test::process2)];
eval { CMSBuilder::process() }; ok ! $@, 'CMSBuilder::process() request check: ' . $@;


1;