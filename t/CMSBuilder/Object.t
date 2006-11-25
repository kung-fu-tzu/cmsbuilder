#!/usr/bin/perl
use strict;
use utf8;

use Test::Simple tests => 35;


use CMSBuilder;

require CMSBuilder::Object;
my $to = {};
bless $to, 'CMSBuilder::Object';

#———————————————————————————————————————————————————————————————————————————————

ok undef ne 0 && '' ne 0, 'undef ne 0 && \'\' ne 0';
ok 0 eq 0, '0 eq 0';


#———————————————————————————————————————————————————————————————————————————————

### создадим тестовый екземпляр
ok $to = CMSBuilder::Object->_perl_new;
ok ref($to) eq 'CMSBuilder::Object';
### props должны возвращать ссылку на хеш
ok ref $to->props eq 'HASH';

#———————————————————————————————————————————————————————————————————————————————

### по умолчанию, class_name возвращает имя класса
ok (CMSBuilder::Object->class_name eq 'CMSBuilder::Object');
ok $to->class_name eq 'CMSBuilder::Object';
### проверяем имя у тестового объекта
# ok $to->name eq 'CMSBuilder::Object без имени', $to->name;

#———————————————————————————————————————————————————————————————————————————————

### создадим тестовые обработчики событий
sub Tests::CMSBuilder::Object::some_func {}
sub Tests::CMSBuilder::Object::other_func {}
sub CMSBuilder::Object::self_func {}


### нельзя регить без параметров
eval { $to->event_reg }; ok $@;
### нельзя регить без второго параметра
eval { $to->event_reg('type') }; ok $@;

### нельзя регить несущ. ф-ции
eval { $to->event_reg('type','not_existed') }; ok $@;
### нельзя регить ссылки, кроме ссылок на код
eval { $to->event_reg('type',[]) }; ok $@;
eval { $to->event_reg('type',{}) }; ok $@;
### можно успешно регить ссылки на код
ok defined $to->event_reg('type',sub {my $o = shift; die if ref $o ne 'CMSBuilder::Object'; return @_;});
### можно успешно регить существующие функции
ok defined $to->event_reg('type','Tests::CMSBuilder::Object::some_func');
### можно успешно регить методы
ok defined $to->event_reg('type','self_func');


### вызов безымянного события вызывает исключение
eval { $to->event_call }; ok $@;
### вызов несущ. типа событий возвращает ложь (не выбрасывает исключ.)
ok ! defined $to->event_call('not_existed_event_type');
### проверим передачу параметров и соответствующие возвращенные значения
ok join('',$to->event_call('type','OK',123,'OK')) eq 'OK123OK';

### проверим __event_call_cancel
ok defined $to->event_reg('type0',sub {$_[0]->{'__event_call_cancel'} = 1; 'a'});
ok defined $to->event_reg('type0',sub {'b'});
ok defined $to->event_reg('type1',sub {return 'x',$to->event_call('type0')});
ok defined $to->event_reg('type1',sub {'x'});
ok defined $to->event_reg('type1',sub {'x'});
ok join('',$to->event_call('type1')) eq 'xaxx';

### нельзя удалять без параметров
eval { $to->event_unreg }; ok $@;
### нельзя удалять без второго параметра
eval { $to->event_unreg('type') }; ok $@;
### нельзя удалять несущ. ф-ции
eval { $to->event_unreg('type','not_existed') }; ok $@;

### нельзя удалять не зареганные ранее ф-ции
ok ! $to->event_unreg('type',sub {});
ok ! $to->event_unreg('type','Tests::CMSBuilder::Object::other_func');

### можно успешно удалять ранее реганые ф-ции
ok $to->event_unreg('type','Tests::CMSBuilder::Object::some_func');
### повторное удаление возвращает ложь
ok ! $to->event_unreg('type','Tests::CMSBuilder::Object::some_func');




#———————————————————————————————————————————————————————————————————————————————

### нельзя вызывать несуществующий метод
ok ! $to->rpc_can('not_existed');
### вызов несущ. метода вызывает исключение
ok ! eval { $to->rpc_call('not_existed'); 1 };

### создадим тестовую функцию
sub CMSBuilder::Object::test_rpc { my $o = shift; die if ref $o ne 'CMSBuilder::Object'; return @_; }
### зарегим тестовую ф-цию как рпц
die unless cmsb_rpc 'CMSBuilder::Object', 'test_rpc', {a => '2'};
### зареганые ф-ции вызывать можно
die unless $to->rpc_can('test_rpc');
### проверим передачу параметров, а заодно и возвращение значений
ok (($to->rpc_call('test_rpc','123'))[0] eq '123');
ok join('', $to->rpc_call('test_rpc','OK',2,'OK')) eq 'OK2OK';


1;