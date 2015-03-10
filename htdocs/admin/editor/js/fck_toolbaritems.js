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
TBI.prototype.Cut			= new TBButton("Cut", "��������"						, DECMD_CUT) ;
TBI.prototype.Copy			= new TBButton("Copy", "����������"					, DECMD_COPY) ;
TBI.prototype.Paste			= new TBButton("Paste", "��������"					, DECMD_PASTE) ;
TBI.prototype.PasteText		= new TBButton("PasteText", "�������� ��� ������� ����� (��� ��������������)"		, "pastePlainText()"		, TBCMD_CUSTOM, "checkDecCommand(DECMD_PASTE)") ;
TBI.prototype.PasteWord		= new TBButton("PasteWord", "�������� ����� �� ��������� MS Word"			, "pasteFromWord()"			, TBCMD_CUSTOM, "checkDecCommand(DECMD_PASTE)") ;
TBI.prototype.Find			= new TBButton("Find", "�����"					, DECMD_FINDTEXT) ;
TBI.prototype.SelectAll		= new TBButton("SelectAll", "�������� ���"				, DECMD_SELECTALL) ;
TBI.prototype.RemoveFormat	= new TBButton("RemoveFormat", "�������� ��������������"			, DECMD_REMOVEFORMAT) ;
TBI.prototype.Link			= new TBButton("Link", "��������/������������� ������"		, "dialogLink()"			, TBCMD_CUSTOM, "checkDecCommand(DECMD_HYPERLINK)") ;
TBI.prototype.RemoveLink	= new TBButton("Unlink", "������� ������"				, DECMD_UNLINK) ;
TBI.prototype.Image			= new TBButton("Image", "��������/������������� �����������"		, "dialogImage()"			, TBCMD_CUSTOM) ;
TBI.prototype.Table			= new TBButton("Table", "��������/������������� �������"		, "dialogTable()"			, TBCMD_CUSTOM) ;
TBI.prototype.Rule			= new TBButton("Rule", "�������������� �����"	, "InsertHorizontalRule"	, TBCMD_DOC) ;
TBI.prototype.SpecialChar	= new TBButton("SpecialChar", "�������� ����������", "insertSpecialChar()"		, TBCMD_CUSTOM) ;
TBI.prototype.Smiley		= new TBButton("Smiley", "�������� �������"			, "insertSmiley()"			, TBCMD_CUSTOM) ;
TBI.prototype.About			= new TBButton("About", "� ���������"	, "about()"					, TBCMD_CUSTOM) ;
TBI.prototype.BreakLine			= new TBButton("BreakLine", "������� ������", "breakLine()", TBCMD_CUSTOM) ;

// Formatting
TBI.prototype.Bold			= new TBButton("Bold", "������"					, DECMD_BOLD) ;
TBI.prototype.Italic		= new TBButton("Italic", "������"					, DECMD_ITALIC) ;
TBI.prototype.Underline		= new TBButton("Underline", "������������"				, DECMD_UNDERLINE) ;
TBI.prototype.StrikeThrough	= new TBButton("StrikeThrough", "�������������"			, "strikethrough"		, TBCMD_DOC) ;
TBI.prototype.Subscript		= new TBButton("Subscript", "������ ������"				, "subscript"			, TBCMD_DOC) ;
TBI.prototype.Superscript	= new TBButton("Superscript", "������� ������"				, "superscript"			, TBCMD_DOC) ;
TBI.prototype.JustifyLeft	= new TBButton("JustifyLeft", "��������� �� ������ ����"			, DECMD_JUSTIFYLEFT) ;
TBI.prototype.JustifyCenter	= new TBButton("JustifyCenter", "��������� �� ������"			, DECMD_JUSTIFYCENTER) ;
TBI.prototype.JustifyRight	= new TBButton("JustifyRight", "��������� �� ������� ����"			, DECMD_JUSTIFYRIGHT) ;
TBI.prototype.JustifyFull	= new TBButton("JustifyFull", "��������� �� ����� �����"			, "JustifyFull"			, TBCMD_DOC) ;
TBI.prototype.Outdent		= new TBButton("Outdent", "��������� ������"			, DECMD_OUTDENT) ;
TBI.prototype.Indent		= new TBButton("Indent"	, "��������� ������"			, DECMD_INDENT) ;
TBI.prototype.Undo			= new TBButton("Undo", "�������� ��������"					, DECMD_UNDO) ;
TBI.prototype.Redo			= new TBButton("Redo", "��������� ��������"					, DECMD_REDO) ;
TBI.prototype.InsertOrderedList		= new TBButton("InsertOrderedList", "������������ ������", DECMD_ORDERLIST) ;
TBI.prototype.InsertUnorderedList	= new TBButton("InsertUnorderedList", "������������� ������", DECMD_UNORDERLIST) ;

// Options
TBI.prototype.ShowTableBorders	= new TBButton("ShowTableBorders", "�������� ������� �������", "showTableBorders()", TBCMD_CUSTOM, "checkShowTableBorders()") ;
TBI.prototype.ShowDetails		= new TBButton("ShowDetails", "�������� ������", "showDetails()", TBCMD_CUSTOM, "checkShowDetails()") ;

// Font
TBI.prototype.FontStyle		= new TBCombo( "FontStyle", "doStyle(this)", ""	, config.StyleNames, config.StyleValues, 'CheckStyle("cmbFontStyle")') ;
TBI.prototype.PagesList		= new TBCombo( "PagesList", "doPageList(this)", "", config.PageNames, config.PageValues, 'CheckPage("cmbPage")') ;
TBI.prototype.FontFormat	= new TBCombo( "FontFormat", "doFormatBlock(this)", "������:", config.BlockFormatNames, config.BlockFormatNames, 'CheckFontFormat("cmbFontFormat")') ;
TBI.prototype.Font		= new TBCombo( "Font", "doFontName(this)", "�����:", config.ToolbarFontNames, config.ToolbarFontNames, 'CheckFontName("cmbFont")') ;
TBI.prototype.FontSize		= new TBCombo( "FontSize", "doFontSize(this)", "", '������ ������;xx-small;x-small;small;medium;large;x-large;xx-large', ';1;2;3;4;5;6;7', 'CheckFontSize("cmbFontSize")') ;
TBI.prototype.TextColor		= new TBButton("TextColor", "���� ������"				, "foreColor()"	, TBCMD_CUSTOM) ;
TBI.prototype.BGColor		= new TBButton("BGColor", "���� ����", "backColor()"	, TBCMD_CUSTOM) ;
TBI.prototype.EditSource	= new TBCheckBox("EditSource", "switchEditMode()", "� ���� HTML", "onViewMode") ;

// This is the object that holds the available toolbar items
var oTB_Items = new TBI() ;