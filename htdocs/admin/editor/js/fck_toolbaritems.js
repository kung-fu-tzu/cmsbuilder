/*
 * FCKeditor - The text editor for internet
 * Copyright (C) 2003 Frederico Caldeira Knabben
 *
 * Licensed under the terms of the GNU Lesser General Public License
 * (http://www.opensource.org/licenses/lgpl-license.php)
 *
 * For further information go to http://www.fredck.com/FCKeditor/ 
 * or contact fckeditor@fredck.com.
 *
 * fck_toolbaritems.js: Defines all the available toolbar items.
 *
 * Authors:
 *   Frederico Caldeira Knabben (fckeditor@fredck.com)
 */

// This class holds the available toolbar items definitions
function TBI() {}

// Standard
TBI.prototype.Cut			= new TBButton("Cut", "Вырезать"						, DECMD_CUT) ;
TBI.prototype.Copy			= new TBButton("Copy", "Копировать"					, DECMD_COPY) ;
TBI.prototype.Paste			= new TBButton("Paste", "Вставить"					, DECMD_PASTE) ;
TBI.prototype.PasteText		= new TBButton("PasteText", "Вставить как простой текст (без форматирования)"		, "pastePlainText()"		, TBCMD_CUSTOM, "checkDecCommand(DECMD_PASTE)") ;
TBI.prototype.PasteWord		= new TBButton("PasteWord", "Вставить текст из редактора MS Word"			, "pasteFromWord()"			, TBCMD_CUSTOM, "checkDecCommand(DECMD_PASTE)") ;
TBI.prototype.Find			= new TBButton("Find", "Найти"					, DECMD_FINDTEXT) ;
TBI.prototype.SelectAll		= new TBButton("SelectAll", "Выделить все"				, DECMD_SELECTALL) ;
TBI.prototype.RemoveFormat	= new TBButton("RemoveFormat", "Отменить форматирование"			, DECMD_REMOVEFORMAT) ;
TBI.prototype.Link			= new TBButton("Link", "Вставить/редактировать ссылку"		, "dialogLink()"			, TBCMD_CUSTOM, "checkDecCommand(DECMD_HYPERLINK)") ;
TBI.prototype.RemoveLink	= new TBButton("Unlink", "Удалить ссылку"				, DECMD_UNLINK) ;
TBI.prototype.Image			= new TBButton("Image", "Вставить/редактировать изображение"		, "dialogImage()"			, TBCMD_CUSTOM) ;
TBI.prototype.Table			= new TBButton("Table", "Вставить/редактировать таблицу"		, "dialogTable()"			, TBCMD_CUSTOM) ;
TBI.prototype.Rule			= new TBButton("Rule", "Горизонтальная линия"	, "InsertHorizontalRule"	, TBCMD_DOC) ;
TBI.prototype.SpecialChar	= new TBButton("SpecialChar", "Вставить спецсимвол", "insertSpecialChar()"		, TBCMD_CUSTOM) ;
TBI.prototype.Smiley		= new TBButton("Smiley", "Вставить смайлик"			, "insertSmiley()"			, TBCMD_CUSTOM) ;
TBI.prototype.About			= new TBButton("About", "О программе"	, "about()"					, TBCMD_CUSTOM) ;
TBI.prototype.BreakLine			= new TBButton("BreakLine", "Перенос строки", "breakLine()", TBCMD_CUSTOM) ;

// Formatting
TBI.prototype.Bold			= new TBButton("Bold", "Жирный"					, DECMD_BOLD) ;
TBI.prototype.Italic		= new TBButton("Italic", "Курсив"					, DECMD_ITALIC) ;
TBI.prototype.Underline		= new TBButton("Underline", "Подчеркнутый"				, DECMD_UNDERLINE) ;
TBI.prototype.StrikeThrough	= new TBButton("StrikeThrough", "Перечеркнутый"			, "strikethrough"		, TBCMD_DOC) ;
TBI.prototype.Subscript		= new TBButton("Subscript", "Нижний индекс"				, "subscript"			, TBCMD_DOC) ;
TBI.prototype.Superscript	= new TBButton("Superscript", "Верхний индекс"				, "superscript"			, TBCMD_DOC) ;
TBI.prototype.JustifyLeft	= new TBButton("JustifyLeft", "Выровнить по левому краю"			, DECMD_JUSTIFYLEFT) ;
TBI.prototype.JustifyCenter	= new TBButton("JustifyCenter", "Выровнить по центру"			, DECMD_JUSTIFYCENTER) ;
TBI.prototype.JustifyRight	= new TBButton("JustifyRight", "Выровнить по правому краю"			, DECMD_JUSTIFYRIGHT) ;
TBI.prototype.JustifyFull	= new TBButton("JustifyFull", "Выровнить по обоим краям"			, "JustifyFull"			, TBCMD_DOC) ;
TBI.prototype.Outdent		= new TBButton("Outdent", "Уменьшить отступ"			, DECMD_OUTDENT) ;
TBI.prototype.Indent		= new TBButton("Indent"	, "Увеличить отступ"			, DECMD_INDENT) ;
TBI.prototype.Undo			= new TBButton("Undo", "Отменить действие"					, DECMD_UNDO) ;
TBI.prototype.Redo			= new TBButton("Redo", "Повторить действие"					, DECMD_REDO) ;
TBI.prototype.InsertOrderedList		= new TBButton("InsertOrderedList", "Нумерованный список", DECMD_ORDERLIST) ;
TBI.prototype.InsertUnorderedList	= new TBButton("InsertUnorderedList", "Маркированный список", DECMD_UNORDERLIST) ;

// Options
TBI.prototype.ShowTableBorders	= new TBButton("ShowTableBorders", "Показать границу таблицы", "showTableBorders()", TBCMD_CUSTOM, "checkShowTableBorders()") ;
TBI.prototype.ShowDetails		= new TBButton("ShowDetails", "Показать детали", "showDetails()", TBCMD_CUSTOM, "checkShowDetails()") ;

// Font
TBI.prototype.FontStyle		= new TBCombo( "FontStyle", "doStyle(this)", ""	, config.StyleNames, config.StyleValues, 'CheckStyle("cmbFontStyle")') ;
TBI.prototype.PagesList		= new TBCombo( "PagesList", "doPageList(this)", "", config.PageNames, config.PageValues, 'CheckPage("cmbPage")') ;
TBI.prototype.FontFormat	= new TBCombo( "FontFormat", "doFormatBlock(this)", "Формат:", config.BlockFormatNames, config.BlockFormatNames, 'CheckFontFormat("cmbFontFormat")') ;
TBI.prototype.Font		= new TBCombo( "Font", "doFontName(this)", "Шрифт:", config.ToolbarFontNames, config.ToolbarFontNames, 'CheckFontName("cmbFont")') ;
TBI.prototype.FontSize		= new TBCombo( "FontSize", "doFontSize(this)", "", 'Размер шрифта;xx-small;x-small;small;medium;large;x-large;xx-large', ';1;2;3;4;5;6;7', 'CheckFontSize("cmbFontSize")') ;
TBI.prototype.TextColor		= new TBButton("TextColor", "Цвет текста"				, "foreColor()"	, TBCMD_CUSTOM) ;
TBI.prototype.BGColor		= new TBButton("BGColor", "Цвет фона", "backColor()"	, TBCMD_CUSTOM) ;
TBI.prototype.EditSource	= new TBCheckBox("EditSource", "switchEditMode()", "В виде HTML", "onViewMode") ;

// This is the object that holds the available toolbar items
var oTB_Items = new TBI() ;