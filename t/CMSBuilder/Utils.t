#!/usr/bin/perl
use strict;
use utf8;

use Test::Simple tests => 101;


use CMSBuilder::Utils;

### тестанем интегратор массивов
eval " integrate_arrays([])) "; ok $@, 'params';
eval " integrate_arrays([],[],[])) "; ok $@, 'params';

ok join('', integrate_arrays(['a','b','c'],[])) eq 'abc',						'only';
ok join('', integrate_arrays(['a','.'],['a','b','c'])) eq 'abc',				'.';
ok join('', integrate_arrays(['a','.','c'],['a','b','c','x'])) eq 'abxc',		'.';
ok join('', integrate_arrays(['a','.','c','.'],['a','b','c','x'])) eq 'abxcbx',	'.';
ok join('', integrate_arrays(['x','*'],['a','b','c'])) eq 'xabc',				'*';
ok join('', integrate_arrays(['*','x','*'],['a','b','c'])) eq 'abcxabc',		'*';
ok join('', integrate_arrays([],['a','b','c'])) eq '',							'empty';
ok join('', integrate_arrays(['a','b','c'],['x','y','z'])) eq 'abc',			'normal';
ok join('', integrate_arrays(['a',1,'c'],['a','b','c'])) eq 'abc',				'digit';
ok join('', integrate_arrays([0,1,2],['a','b','c'])) eq 'abc',					'digit';
ok join('', integrate_arrays([2,1,0],['a','b','c'])) eq 'cba',					'digit';
ok join('', integrate_arrays([200,201,202],['a','b','c'])) eq '',				'digit';

### теперь проверим, работает ли "минус"
ok join('', integrate_arrays(['x','a','-.','c'],['x','y','z'])) eq 'xazyc',		'minus .';
ok join('', integrate_arrays(['x','a','-*','c'],['x','y','z'])) eq 'xazyxc',	'minus *';
ok join('', integrate_arrays(['-*','x','*'],['a','b','c'])) eq 'cbaxabc',		'minus -* *';
ok join('', integrate_arrays(['-.','b','.'],['a','b','c'])) eq 'cabac',			'minus -. .';


#———————————————————————————————————————————————————————————————————————————————

### протестим падежи
ok rus_case(0,['ни одного','яблоко','яблока','яблок']) eq 'ни одного',			'rus_case0';

ok rus_case(1,['ни одного','яблоко','яблока','яблок']) eq 'яблоко',				'rus_case1';

ok rus_case(2,['ни одного','яблоко','яблока','яблок']) eq 'яблока',				'rus_case2';
ok rus_case(3,['ни одного','яблоко','яблока','яблок']) eq 'яблока',				'rus_case3';
ok rus_case(4,['ни одного','яблоко','яблока','яблок']) eq 'яблока',				'rus_case4';

ok rus_case(5,['ни одного','яблоко','яблока','яблок']) eq 'яблок',				'rus_case5';
ok rus_case(6,['ни одного','яблоко','яблока','яблок']) eq 'яблок',				'rus_case6';
ok rus_case(7,['ни одного','яблоко','яблока','яблок']) eq 'яблок',				'rus_case7';
ok rus_case(8,['ни одного','яблоко','яблока','яблок']) eq 'яблок',				'rus_case8';
ok rus_case(9,['ни одного','яблоко','яблока','яблок']) eq 'яблок',				'rus_case9';
ok rus_case(10,['ни одного','яблоко','яблока','яблок']) eq 'яблок',				'rus_case10';
ok rus_case(11,['ни одного','яблоко','яблока','яблок']) eq 'яблок',				'rus_case11';
ok rus_case(12,['ни одного','яблоко','яблока','яблок']) eq 'яблок',				'rus_case12';
ok rus_case(19,['ни одного','яблоко','яблока','яблок']) eq 'яблок',				'rus_case19';
ok rus_case(20,['ни одного','яблоко','яблока','яблок']) eq 'яблок',				'rus_case20';

ok rus_case(21,['ни одного','яблоко','яблока','яблок']) eq 'яблоко',			'rus_case21';

ok rus_case(22,['ни одного','яблоко','яблока','яблок']) eq 'яблока',			'rus_case22';

ok rus_case(50,['ни одного','яблоко','яблока','яблок']) eq 'яблок',				'rus_case50';

### а еще оно умеет вставлять текст
ok rus_case(1,['','яб%dлоко','','']) eq 'яб1локо',								'rus_case22';


#———————————————————————————————————————————————————————————————————————————————


my $ar = [];
my $hr = {x => 'abc', r => $ar};
ok decode_utf8_hashref($hr) == $hr,												'decode_utf8_hashref same';
ok decode_utf8_hashref($hr)->{x} eq 'abc',										'decode_utf8_hashref val';
ok decode_utf8_hashref($hr)->{r} == $ar,										'decode_utf8_hashref ref';


#———————————————————————————————————————————————————————————————————————————————


ok catch_out {print 'abc';} eq 'abc',											'catch_out';
ok join('', catch_out {print 'abc'; 777;}) eq 'abc777',							'catch_out';
ok join('', catch_out {print 'abc'; 7,6,5;}) eq 'abc765',						'catch_out';


#———————————————————————————————————————————————————————————————————————————————


ok parsetpl('xxx${a}xxx${b}xxx${c}xxx',{a => 1, b => 2, c => 3})
	eq 'xxx1xxx2xxx3xxx',														'parsetpl';
ok parsetpl('xxx$xxx${}xxx',{}) eq 'xxx$xxx${}xxx',								'parsetpl';


#———————————————————————————————————————————————————————————————————————————————


ok join('',listdirs('t/CMSBuilder/Utils')) eq 'abc',							'listdirs';
ok join(' ',sort( listfiles('t/CMSBuilder/Utils','pm','pk'))) eq 'o.pk x.pm y.pm z.pm','listfiles';
#warn join(' ', sort( listfiles('t/CMSBuilder/Utils','pm','pk')));

#———————————————————————————————————————————————————————————————————————————————


ok indexA(['a','b','c'],'b') == 1,												'indexA';
ok indexA(['a','b','c'],'x') == -1,												'indexA';


#———————————————————————————————————————————————————————————————————————————————


ok epoch2ts(1234567890) == 20090214023130,										'epoch2ts';
ok epoch2ts(0) == 19700101030000,												'epoch2ts';
#die ts2epoch(19700101030000) . ' ' . epoch2ts(1);
ok ts2epoch(19700101030000) == 0,												'ts2epoch';
ok ts2epoch(20090214023130) == 1234567890,										'ts2epoch';

ok toDateTimeStr(20050816174452) eq '16 августа 2005г., 17:44:52',				'toDateTimeStr';
ok toDateStr(20050816174452) eq '16 августа 2005г.',							'toDateStr';
ok toDateStr(20050816) eq '16 августа 2005г.',									'toDateStr';


#———————————————————————————————————————————————————————————————————————————————

ok HTMLfilter(qq('"&<>'"&<>)) eq '&#039;&quot;&amp;&lt;&gt;&#039;&quot;&amp;&lt;&gt;', 'HTMLfilter';
ok escape(qq(' " \\ \n \r)) eq qq(\\' \\" \\\\ \\n \\r),						'escape';


#———————————————————————————————————————————————————————————————————————————————

ok len2size(1) eq '1 байт';
ok len2size(2) eq '2 байта';
ok len2size(5) eq '5 байт';
ok len2size(12) eq '12 байт';
ok len2size(22) eq '22 байта';
ok len2size(41) eq '41 байт';

ok len2size(1024-1) eq '1023 байта';
ok len2size(1024) eq '1 Кб';
ok len2size(1048576-1) eq '1023,9 Кб';
ok len2size(1048576) eq '1 Мб';

ok len2size(1073741824) eq '1 Гб';
ok len2size(1099511627776) eq '1 Тб';
ok len2size(1048576 * 1073741824) eq '1 Пб';
ok len2size(1073741824 * 1073741824) eq '1 Эб';
ok len2size(1099511627776 * 1073741824) eq '1 Зб';
ok len2size(1099511627776 * 1099511627776) eq '1 Йб';

ok round2(12.3456)  == 12.3;


#———————————————————————————————————————————————————————————————————————————————


ok translit('Съешь еще этих мягких французских булок, да выпей чаю.') eq 'Sqewq ewe etih mygkih francuzskih bulok, da vipei 4au.';
ok translit('АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЬЫЪЭЮЯабвгдеёжзийклмнопрстуфхцчшщьыъэюя') eq 'ABVGDEEJZIIKLMNOPRSTUFHC4WWQIQEUYabvgdeejziiklmnoprstufhc4wwqiqeuy';


#———————————————————————————————————————————————————————————————————————————————


ok path_it('/') eq '/';
ok path_it('/a/b/c') eq '/a/b/c';
ok path_it('/a/b/c/') eq '/a/b/c/';
ok path_it('a/b/c/') eq 'a/b/c/';
ok path_it('../a/b/c/') eq 'a/b/c/';
ok path_it('/a/b/c///') eq '/a/b/c/';
ok path_it('/a/b/../c/') eq '/a/b/c/';
ok path_it('/a/b/./c/') eq '/a/b/c/';
ok path_it('/////') eq '/';
ok path_it('\\') eq '/';
ok path_it('/./b/../c/') eq '/b/c/';
ok path_it('./a/b/../c/') eq 'a/b/c/';
ok path_it('/a/b/../../c/') eq '/a/b/c/';

ok path_it('/a/b/.../c/') eq '/a/b/.../c/';
ok path_it('.../c/') eq '.../c/';
ok path_it('/a/b/..../c/') eq '/a/b/..../c/';


#———————————————————————————————————————————————————————————————————————————————

ok MD5('') eq 'd41d8cd98f00b204e9800998ecf8427e';
ok MD5('1zM_+= @') eq '0cc8a3f08a4d5f911a61660273b1f14d';

#———————————————————————————————————————————————————————————————————————————————


ok escape(qq(\'\"\n\r)) eq q(\\'\\"\\n\\r);

ok HTMLfilter('&<>\'"') eq '&amp;&lt;&gt;&#039;&quot;';


#———————————————————————————————————————————————————————————————————————————————


ok CMSBuilder::Utils::base64m('Привет! Hello!') eq '=?UTF-8?B?0J/RgNC40LLQtdGCISBIZWxsbyE=?=';


#———————————————————————————————————————————————————————————————————————————————


ok CMSBuilder::Utils::sendmail_make()
eq
'To: 
From: 
Subject: 
Content-type: text/plain; charset=utf-8

';

ok CMSBuilder::Utils::sendmail_make
(
	to => 'to@test.ru',
	from => 'from@test.ru',
	subject => 'Something about Merry',
	message => 'JAPH'
)
eq
'To: to@test.ru
From: from@test.ru
Subject: Something about Merry
Content-type: text/plain; charset=utf-8

JAPH';

ok CMSBuilder::Utils::sendmail_make
(
	to => 'Ванька <to@test.ru>',
	from => 'Манька <from@test.ru>',
	subject => 'По делу',
	message => 'Дело!'
)
eq
'To: =?UTF-8?B?0JLQsNC90YzQutCw?= <to@test.ru>
From: =?UTF-8?B?0JzQsNC90YzQutCw?= <from@test.ru>
Subject: =?UTF-8?B?0J/Qvg==?= =?UTF-8?B?0LTQtdC70YM=?=
Content-type: text/plain; charset=utf-8

Дело!';


#———————————————————————————————————————————————————————————————————————————————



1;