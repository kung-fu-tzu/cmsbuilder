# phpMyAdmin SQL Dump
# version 2.5.6
# http://www.phpmyadmin.net
#
# Хост: localhost
# Время создания: Ноя 19 2004 г., 00:38
# Версия сервера: 3.23.56
# Версия PHP: 4.3.4
# 
# БД : `engine`
# 

# --------------------------------------------------------

#
# Структура таблицы `access`
#

CREATE TABLE `access` (
  `ID` int(11) NOT NULL auto_increment,
  `url` varchar(50) NOT NULL default '',
  `memb` varchar(50) NOT NULL default '',
  `code` int(11) NOT NULL default '0',
  PRIMARY KEY  (`ID`),
  KEY `memb` (`memb`),
  KEY `url` (`url`)
) TYPE=MyISAM PACK_KEYS=0 AUTO_INCREMENT=4 ;

#
# Дамп данных таблицы `access`
#

INSERT INTO `access` VALUES (1, 'ModHttp1', 'all', 30);
INSERT INTO `access` VALUES (3, 'ModHttp1', 'owner', 31);

# --------------------------------------------------------

#
# Структура таблицы `arr_Dir1`
#

CREATE TABLE `arr_Dir1` (
  `num` int(11) NOT NULL auto_increment,
  `ID` int(11) NOT NULL default '-1',
  `CLASS` varchar(20) NOT NULL default '',
  KEY `num` (`num`)
) TYPE=MyISAM AUTO_INCREMENT=5 ;

#
# Дамп данных таблицы `arr_Dir1`
#

INSERT INTO `arr_Dir1` VALUES (1, 8, 'Papa');
INSERT INTO `arr_Dir1` VALUES (2, 5, 'Elem');
INSERT INTO `arr_Dir1` VALUES (3, 6, 'Dir');

# --------------------------------------------------------

#
# Структура таблицы `arr_Dir2`
#

CREATE TABLE `arr_Dir2` (
  `num` int(11) NOT NULL auto_increment,
  `ID` int(11) NOT NULL default '-1',
  `CLASS` varchar(20) NOT NULL default '',
  KEY `num` (`num`)
) TYPE=MyISAM AUTO_INCREMENT=11 ;

#
# Дамп данных таблицы `arr_Dir2`
#

INSERT INTO `arr_Dir2` VALUES (1, 6, 'Papa');
INSERT INTO `arr_Dir2` VALUES (2, 15, 'Elem');
INSERT INTO `arr_Dir2` VALUES (3, 2, 'Papa');
INSERT INTO `arr_Dir2` VALUES (4, 14, 'Elem');
INSERT INTO `arr_Dir2` VALUES (5, 27, 'Elem');
INSERT INTO `arr_Dir2` VALUES (6, 3, 'Dir');

# --------------------------------------------------------

#
# Структура таблицы `arr_Dir3`
#

CREATE TABLE `arr_Dir3` (
  `num` int(11) NOT NULL auto_increment,
  `ID` int(11) NOT NULL default '-1',
  `CLASS` varchar(20) NOT NULL default '',
  KEY `num` (`num`)
) TYPE=MyISAM AUTO_INCREMENT=6 ;

#
# Дамп данных таблицы `arr_Dir3`
#

INSERT INTO `arr_Dir3` VALUES (1, 4, 'Papa');
INSERT INTO `arr_Dir3` VALUES (2, 2, 'Elem');
INSERT INTO `arr_Dir3` VALUES (3, 12, 'Elem');
INSERT INTO `arr_Dir3` VALUES (4, 5, 'Papa');

# --------------------------------------------------------

#
# Структура таблицы `arr_Dir4`
#

CREATE TABLE `arr_Dir4` (
  `num` int(11) NOT NULL auto_increment,
  `ID` int(11) NOT NULL default '-1',
  `CLASS` varchar(20) NOT NULL default '',
  `SHCUT` smallint(6) NOT NULL default '0',
  KEY `num` (`num`)
) TYPE=MyISAM AUTO_INCREMENT=2 ;

#
# Дамп данных таблицы `arr_Dir4`
#

INSERT INTO `arr_Dir4` VALUES (1, 5, 'Dir', 0);

# --------------------------------------------------------

#
# Структура таблицы `arr_Dir5`
#

CREATE TABLE `arr_Dir5` (
  `num` int(11) NOT NULL auto_increment,
  `ID` int(11) NOT NULL default '-1',
  `CLASS` varchar(20) NOT NULL default '',
  `SHCUT` smallint(6) NOT NULL default '0',
  KEY `num` (`num`)
) TYPE=MyISAM AUTO_INCREMENT=2 ;

#
# Дамп данных таблицы `arr_Dir5`
#

INSERT INTO `arr_Dir5` VALUES (1, 4, 'Dir', 0);

# --------------------------------------------------------

#
# Структура таблицы `arr_ModHttp1`
#

CREATE TABLE `arr_ModHttp1` (
  `num` int(11) NOT NULL auto_increment,
  `ID` int(11) NOT NULL default '-1',
  `CLASS` varchar(20) NOT NULL default '',
  KEY `num` (`num`)
) TYPE=MyISAM AUTO_INCREMENT=29 ;

#
# Дамп данных таблицы `arr_ModHttp1`
#

INSERT INTO `arr_ModHttp1` VALUES (1, 1, 'Dir');
INSERT INTO `arr_ModHttp1` VALUES (2, 1, 'Papa');
INSERT INTO `arr_ModHttp1` VALUES (3, 2, 'Dir');
INSERT INTO `arr_ModHttp1` VALUES (4, 3, 'Elem');
INSERT INTO `arr_ModHttp1` VALUES (5, 3, 'Papa');
INSERT INTO `arr_ModHttp1` VALUES (6, 7, 'Elem');
INSERT INTO `arr_ModHttp1` VALUES (7, 7, 'Papa');
INSERT INTO `arr_ModHttp1` VALUES (8, 8, 'Elem');
INSERT INTO `arr_ModHttp1` VALUES (9, 9, 'Elem');
INSERT INTO `arr_ModHttp1` VALUES (10, 10, 'Elem');
INSERT INTO `arr_ModHttp1` VALUES (11, 13, 'Elem');
INSERT INTO `arr_ModHttp1` VALUES (12, 16, 'Elem');

# --------------------------------------------------------

#
# Структура таблицы `arr_ModRoot1`
#

CREATE TABLE `arr_ModRoot1` (
  `num` int(11) NOT NULL auto_increment,
  `ID` int(11) NOT NULL default '-1',
  `CLASS` varchar(20) NOT NULL default '',
  KEY `num` (`num`)
) TYPE=MyISAM AUTO_INCREMENT=5 ;

#
# Дамп данных таблицы `arr_ModRoot1`
#

INSERT INTO `arr_ModRoot1` VALUES (1, 1, 'ModHttp');
INSERT INTO `arr_ModRoot1` VALUES (2, 1, 'ModSysInfo');
INSERT INTO `arr_ModRoot1` VALUES (3, 1, 'ModUsers');

# --------------------------------------------------------

#
# Структура таблицы `arr_ModUsers1`
#

CREATE TABLE `arr_ModUsers1` (
  `num` int(11) NOT NULL auto_increment,
  `ID` int(11) NOT NULL default '-1',
  `CLASS` varchar(20) NOT NULL default '',
  KEY `num` (`num`)
) TYPE=MyISAM AUTO_INCREMENT=5 ;

#
# Дамп данных таблицы `arr_ModUsers1`
#

INSERT INTO `arr_ModUsers1` VALUES (1, 1, 'UserGroup');
INSERT INTO `arr_ModUsers1` VALUES (2, 3, 'UserGroup');
INSERT INTO `arr_ModUsers1` VALUES (3, 2, 'UserGroup');

# --------------------------------------------------------

#
# Структура таблицы `arr_UserGroup1`
#

CREATE TABLE `arr_UserGroup1` (
  `num` int(11) NOT NULL auto_increment,
  `ID` int(11) NOT NULL default '-1',
  `CLASS` varchar(20) NOT NULL default '',
  KEY `num` (`num`)
) TYPE=MyISAM AUTO_INCREMENT=2 ;

#
# Дамп данных таблицы `arr_UserGroup1`
#

INSERT INTO `arr_UserGroup1` VALUES (1, 1, 'User');

# --------------------------------------------------------

#
# Структура таблицы `arr_UserGroup2`
#

CREATE TABLE `arr_UserGroup2` (
  `num` int(11) NOT NULL auto_increment,
  `ID` int(11) NOT NULL default '-1',
  `CLASS` varchar(20) NOT NULL default '',
  `SHCUT` smallint(6) NOT NULL default '0',
  KEY `num` (`num`)
) TYPE=MyISAM AUTO_INCREMENT=2 ;

#
# Дамп данных таблицы `arr_UserGroup2`
#

INSERT INTO `arr_UserGroup2` VALUES (1, 2, 'User', 0);

# --------------------------------------------------------

#
# Структура таблицы `arr_UserGroup3`
#

CREATE TABLE `arr_UserGroup3` (
  `num` int(11) NOT NULL auto_increment,
  `ID` int(11) NOT NULL default '-1',
  `CLASS` varchar(20) NOT NULL default '',
  KEY `num` (`num`)
) TYPE=MyISAM AUTO_INCREMENT=2 ;

#
# Дамп данных таблицы `arr_UserGroup3`
#

INSERT INTO `arr_UserGroup3` VALUES (1, 3, 'User');

# --------------------------------------------------------

#
# Структура таблицы `dbo_Dir`
#

CREATE TABLE `dbo_Dir` (
  `ID` int(11) NOT NULL auto_increment,
  `OID` int(11) NOT NULL default '-1',
  `ATS` timestamp(14) NOT NULL,
  `CTS` timestamp(14) NOT NULL,
  `PAPA_ID` int(11) NOT NULL default '0',
  `PAPA_CLASS` varchar(20) NOT NULL default '',
  `name` varchar(100) NOT NULL default '',
  `onpage` int(11) NOT NULL default '0',
  PRIMARY KEY  (`ID`)
) TYPE=MyISAM AUTO_INCREMENT=7 ;

#
# Дамп данных таблицы `dbo_Dir`
#

INSERT INTO `dbo_Dir` VALUES (1, 1, 20041112222837, 20041110040047, 1, 'ModHttp', '', 20);
INSERT INTO `dbo_Dir` VALUES (2, 1, 20041115162105, 20041111022747, 1, 'ModHttp', '', 20);
INSERT INTO `dbo_Dir` VALUES (3, 1, 20041118041422, 20041114232134, 2, 'Dir', 'Название', 5);
INSERT INTO `dbo_Dir` VALUES (4, 1, 20041118041538, 20041118041507, 5, 'Dir', '1', 20);
INSERT INTO `dbo_Dir` VALUES (6, 1, 20041118132142, 20041118132141, 1, 'Dir', 'Создание', 7);
INSERT INTO `dbo_Dir` VALUES (5, 1, 20041118041515, 20041118041515, 4, 'Dir', '2', 0);

# --------------------------------------------------------

#
# Структура таблицы `dbo_Elem`
#

CREATE TABLE `dbo_Elem` (
  `ID` int(11) NOT NULL auto_increment,
  `OID` int(11) NOT NULL default '-1',
  `ATS` timestamp(14) NOT NULL,
  `CTS` timestamp(14) NOT NULL,
  `PAPA_ID` int(11) NOT NULL default '0',
  `PAPA_CLASS` varchar(20) NOT NULL default '',
  `name` varchar(100) NOT NULL default '',
  `etext` text NOT NULL,
  `tf` varchar(10) NOT NULL default '',
  PRIMARY KEY  (`ID`)
) TYPE=MyISAM AUTO_INCREMENT=32 ;

#
# Дамп данных таблицы `dbo_Elem`
#

INSERT INTO `dbo_Elem` VALUES (1, 1, 20041117212244, 20041110040102, -1, '', '', '', '');
INSERT INTO `dbo_Elem` VALUES (2, 1, 20041114232217, 20041110040113, 3, 'Dir', '', '', '');
INSERT INTO `dbo_Elem` VALUES (3, 1, 20041114233100, 20041110040125, 1, 'ModHttp', '999', '', '');
INSERT INTO `dbo_Elem` VALUES (4, 1, 20041112220041, 20041110040206, 1, 'Papa', 'Название', '', '');
INSERT INTO `dbo_Elem` VALUES (5, 1, 20041114232956, 20041111022612, 1, 'Dir', '777', '', '');
INSERT INTO `dbo_Elem` VALUES (6, 1, 20041117212101, 20041111022620, -1, '', '', '', '');
INSERT INTO `dbo_Elem` VALUES (7, 1, 20041111022629, 20041111022629, 1, 'ModHttp', '', '', '');
INSERT INTO `dbo_Elem` VALUES (8, 1, 20041111022637, 20041111022637, 1, 'ModHttp', '', '', '');
INSERT INTO `dbo_Elem` VALUES (9, 1, 20041111022647, 20041111022646, 1, 'ModHttp', '', '', '');
INSERT INTO `dbo_Elem` VALUES (10, 1, 20041111022657, 20041111022656, 1, 'ModHttp', '', '', '');
INSERT INTO `dbo_Elem` VALUES (16, 1, 20041115165748, 20041115165748, 1, 'ModHttp', '', '', '');
INSERT INTO `dbo_Elem` VALUES (12, 1, 20041114232227, 20041111022721, 3, 'Dir', '', '', '');
INSERT INTO `dbo_Elem` VALUES (13, 1, 20041111022734, 20041111022734, 1, 'ModHttp', '', '', '');
INSERT INTO `dbo_Elem` VALUES (14, 1, 20041118035328, 20041111022802, 2, 'Dir', '', '', '');
INSERT INTO `dbo_Elem` VALUES (15, 1, 20041118035349, 20041111022816, 2, 'Dir', '', '', '');
INSERT INTO `dbo_Elem` VALUES (17, 1, 20041115170412, 20041115170412, 2, 'Papa', '', '', '');
INSERT INTO `dbo_Elem` VALUES (18, 1, 20041115170427, 20041115170427, 3, 'Papa', '', '', '');
INSERT INTO `dbo_Elem` VALUES (19, 1, 20041115201847, 20041115201847, 0, '', '', '', '');
INSERT INTO `dbo_Elem` VALUES (20, 1, 20041115202238, 20041115202238, 1, 'ModHttp', '', '', '');
INSERT INTO `dbo_Elem` VALUES (21, 1, 20041115202403, 20041115202403, 0, '', '', '', '');
INSERT INTO `dbo_Elem` VALUES (31, 1, 20041118131832, 20041118131832, 8, 'Papa', '', '', '');
INSERT INTO `dbo_Elem` VALUES (23, 1, 20041115202845, 20041115202845, 0, '', '', '', '');
INSERT INTO `dbo_Elem` VALUES (25, 1, 20041115203537, 20041115203537, 4, 'Papa', '', '', '');
INSERT INTO `dbo_Elem` VALUES (26, 1, 20041115203552, 20041115203552, 5, 'Papa', '', '', '');
INSERT INTO `dbo_Elem` VALUES (27, 1, 20041115210911, 20041115210910, 2, 'Dir', '', '', '');
INSERT INTO `dbo_Elem` VALUES (29, 1, 20041115211716, 20041115211716, 6, 'Papa', '', '', '');
INSERT INTO `dbo_Elem` VALUES (30, 1, 20041115211922, 20041115211922, 7, 'Papa', '', '', '');

# --------------------------------------------------------

#
# Структура таблицы `dbo_ModHttp`
#

CREATE TABLE `dbo_ModHttp` (
  `ID` int(11) NOT NULL auto_increment,
  `OID` int(11) NOT NULL default '-1',
  `ATS` timestamp(14) NOT NULL,
  `CTS` timestamp(14) NOT NULL,
  `PAPA_ID` int(11) NOT NULL default '0',
  `PAPA_CLASS` varchar(20) NOT NULL default '',
  `name` varchar(50) NOT NULL default '',
  `dolist` int(1) NOT NULL default '0',
  PRIMARY KEY  (`ID`)
) TYPE=MyISAM AUTO_INCREMENT=2 ;

#
# Дамп данных таблицы `dbo_ModHttp`
#

INSERT INTO `dbo_ModHttp` VALUES (1, 1, 20041115162640, 20041110015544, -1, '', 'Сайт', 0);

# --------------------------------------------------------

#
# Структура таблицы `dbo_ModRoot`
#

CREATE TABLE `dbo_ModRoot` (
  `ID` int(11) NOT NULL auto_increment,
  `OID` int(11) NOT NULL default '-1',
  `ATS` timestamp(14) NOT NULL,
  `CTS` timestamp(14) NOT NULL,
  `PAPA_ID` int(11) NOT NULL default '0',
  `PAPA_CLASS` varchar(20) NOT NULL default '',
  `name` varchar(100) NOT NULL default '',
  PRIMARY KEY  (`ID`)
) TYPE=MyISAM AUTO_INCREMENT=2 ;

#
# Дамп данных таблицы `dbo_ModRoot`
#

INSERT INTO `dbo_ModRoot` VALUES (1, 1, 20041110015353, 20041110015352, 0, '', 'Модули');

# --------------------------------------------------------

#
# Структура таблицы `dbo_ModSysInfo`
#

CREATE TABLE `dbo_ModSysInfo` (
  `ID` int(11) NOT NULL auto_increment,
  `OID` int(11) NOT NULL default '-1',
  `ATS` timestamp(14) NOT NULL,
  `CTS` timestamp(14) NOT NULL,
  `PAPA_ID` int(11) NOT NULL default '0',
  `PAPA_CLASS` varchar(20) NOT NULL default '',
  `name` varchar(50) NOT NULL default '',
  `dolist` int(1) NOT NULL default '0',
  PRIMARY KEY  (`ID`)
) TYPE=MyISAM AUTO_INCREMENT=2 ;

#
# Дамп данных таблицы `dbo_ModSysInfo`
#

INSERT INTO `dbo_ModSysInfo` VALUES (1, 1, 20041110015546, 20041110015544, -1, '', 'Информация', 0);

# --------------------------------------------------------

#
# Структура таблицы `dbo_ModUsers`
#

CREATE TABLE `dbo_ModUsers` (
  `ID` int(11) NOT NULL auto_increment,
  `OID` int(11) NOT NULL default '-1',
  `ATS` timestamp(14) NOT NULL,
  `CTS` timestamp(14) NOT NULL,
  `PAPA_ID` int(11) NOT NULL default '0',
  `PAPA_CLASS` varchar(20) NOT NULL default '',
  `name` varchar(50) NOT NULL default '',
  `dolist` int(1) NOT NULL default '0',
  PRIMARY KEY  (`ID`)
) TYPE=MyISAM AUTO_INCREMENT=2 ;

#
# Дамп данных таблицы `dbo_ModUsers`
#

INSERT INTO `dbo_ModUsers` VALUES (1, 1, 20041110015546, 20041110015545, -1, '', 'Пользователи', 0);

# --------------------------------------------------------

#
# Структура таблицы `dbo_Papa`
#

CREATE TABLE `dbo_Papa` (
  `ID` int(11) NOT NULL auto_increment,
  `OID` int(11) NOT NULL default '-1',
  `ATS` timestamp(14) NOT NULL,
  `CTS` timestamp(14) NOT NULL,
  `PAPA_ID` int(11) NOT NULL default '0',
  `PAPA_CLASS` varchar(20) NOT NULL default '',
  `son` int(11) NOT NULL default '0',
  `name` varchar(100) NOT NULL default '',
  `etext` text NOT NULL,
  PRIMARY KEY  (`ID`)
) TYPE=MyISAM AUTO_INCREMENT=9 ;

#
# Дамп данных таблицы `dbo_Papa`
#

INSERT INTO `dbo_Papa` VALUES (1, 1, 20041110040206, 20041110040205, 1, 'ModHttp', 4, '', 'jjjj<FONT size=5>jjj</FONT>jjjjjj');
INSERT INTO `dbo_Papa` VALUES (2, 1, 20041118035337, 20041115170412, 2, 'Dir', 17, '', '');
INSERT INTO `dbo_Papa` VALUES (3, 1, 20041115170427, 20041115170427, 1, 'ModHttp', 18, '', '');
INSERT INTO `dbo_Papa` VALUES (4, 1, 20041115203538, 20041115203537, 3, 'Dir', 25, '', '');
INSERT INTO `dbo_Papa` VALUES (5, 1, 20041115203553, 20041115203552, 3, 'Dir', 26, '', '');
INSERT INTO `dbo_Papa` VALUES (6, 1, 20041118035403, 20041115211716, 2, 'Dir', 29, '', '');
INSERT INTO `dbo_Papa` VALUES (7, 1, 20041115211922, 20041115211922, 1, 'ModHttp', 30, '', '');
INSERT INTO `dbo_Papa` VALUES (8, 1, 20041118131832, 20041118131832, 0, '', 31, '', '');

# --------------------------------------------------------

#
# Структура таблицы `dbo_User`
#

CREATE TABLE `dbo_User` (
  `ID` int(11) NOT NULL auto_increment,
  `OID` int(11) NOT NULL default '-1',
  `ATS` timestamp(14) NOT NULL,
  `CTS` timestamp(14) NOT NULL,
  `PAPA_ID` int(11) NOT NULL default '0',
  `PAPA_CLASS` varchar(20) NOT NULL default '',
  `sid` varchar(32) NOT NULL default '',
  `email` varchar(50) NOT NULL default '',
  `icq` int(11) NOT NULL default '0',
  `city` varchar(30) NOT NULL default '',
  `name` varchar(50) NOT NULL default '',
  `login` varchar(50) NOT NULL default '',
  `pas` varchar(50) NOT NULL default '',
  PRIMARY KEY  (`ID`)
) TYPE=MyISAM AUTO_INCREMENT=4 ;

#
# Дамп данных таблицы `dbo_User`
#

INSERT INTO `dbo_User` VALUES (1, 1, 20041118131919, 20041110015545, 1, 'UserGroup', 'c8c00e0d6ba57f93825b21232e416bf8', '', 0, '', 'Администратор', 'admin', 'af84ca1579248d3d2debdbcc2de2fe03');
INSERT INTO `dbo_User` VALUES (2, 1, 20041110015546, 20041110015546, 2, 'UserGroup', '', '', 0, '', 'Гость', '', '');
INSERT INTO `dbo_User` VALUES (3, 1, 20041117191315, 20041112221137, 3, 'UserGroup', '0', '', 0, '', 'Вася', 'vasya', 'af84ca1579248d3d2debdbcc2de2fe03');

# --------------------------------------------------------

#
# Структура таблицы `dbo_UserGroup`
#

CREATE TABLE `dbo_UserGroup` (
  `ID` int(11) NOT NULL auto_increment,
  `OID` int(11) NOT NULL default '-1',
  `ATS` timestamp(14) NOT NULL,
  `CTS` timestamp(14) NOT NULL,
  `PAPA_ID` int(11) NOT NULL default '0',
  `PAPA_CLASS` varchar(20) NOT NULL default '',
  `html` int(1) NOT NULL default '0',
  `cms` int(1) NOT NULL default '0',
  `files` int(1) NOT NULL default '0',
  `name` varchar(100) NOT NULL default '',
  `root` int(1) NOT NULL default '0',
  `cpanel` int(1) NOT NULL default '0',
  PRIMARY KEY  (`ID`)
) TYPE=MyISAM AUTO_INCREMENT=4 ;

#
# Дамп данных таблицы `dbo_UserGroup`
#

INSERT INTO `dbo_UserGroup` VALUES (1, 1, 20041110015545, 20041110015545, 1, 'ModUsers', 1, 1, 1, 'Администраторы', 1, 1);
INSERT INTO `dbo_UserGroup` VALUES (2, 1, 20041110015546, 20041110015545, 1, 'ModUsers', 0, 0, 0, 'Гости', 0, 0);
INSERT INTO `dbo_UserGroup` VALUES (3, 1, 20041112220748, 20041112220747, 1, 'ModUsers', 1, 1, 1, 'Модеры', 0, 0);
