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
 * fck_actions.js: Actions called by the toolbar.
 *
 * Authors:
 *   Frederico Caldeira Knabben (fckeditor@fredck.com)
 */
 
function decCommand(cmdId, cmdExecOpt, url)
{
	var status = objContent.QueryStatus(cmdId) ;
	
	if ( status != DECMDF_DISABLED && status != DECMDF_NOTSUPPORTED )
	{
		if (cmdExecOpt == null) cmdExecOpt = OLECMDEXECOPT_DODEFAULT ;
		objContent.ExecCommand(cmdId, cmdExecOpt, url) ;
	}
	objContent.focus() ;
}

function docCommand(command)
{
	objContent.DOM.execCommand(command) ;
	objContent.focus();
}

function doStyle(command)
{
	var oSelection = objContent.DOM.selection ;
	var oTextRange = oSelection.createRange() ;
	
	if (oSelection.type == "Text")
	{
		decCommand(DECMD_REMOVEFORMAT);
		if (!FCKFormatBlockNames) loadFormatBlockNames() ;
		doFormatBlock( FCKFormatBlockNames[0] );	// This value is loaded at CheckFontFormat()
 
 		el  = "FONT";
		cls = command.value;
		/*xx = command.value.indexOf(".");
		if (xx > 0)
		{
                	el  = command.value.substring(0,xx);
                	cls = command.value.substring(xx+1, command.value.length);
                }*/
		var oFont = document.createElement(el);
		oFont.innerHTML = oTextRange.htmlText ;
		
		var oParent = oTextRange.parentElement() ;
		var oFirstChild = oFont.firstChild ;
		
		if (oFirstChild.nodeType == 1 && oFirstChild.outerHTML == oFont.innerHTML && 
				(oFirstChild.tagName == "SPAN"
				|| oFirstChild.tagName == "FONT"
				|| oFirstChild.tagName == "P"
				|| oFirstChild.tagName == "DIV"))
		{
			oParent.className = cls ;
		}
		else
		{
			oFont.className = cls ;
			oTextRange.pasteHTML( oFont.outerHTML ) ;
		}
	}
	else if (oSelection.type == "Control" && oTextRange.length == 1)
	{
		var oControl = oTextRange.item(0) ;
		oControl.className = command.value ;
	}
	
	command.selectedIndex = 0 ;
	
	objContent.focus();
}

function doPageList(command)
{
	var oSelection = objContent.DOM.selection ;
	var oTextRange = oSelection.createRange() ;
	
	var sUrl = command.value ;
	
	if (sUrl == "")
		decCommand( DECMD_UNLINK ) ;
	else
	{
		decCommand( DECMD_HYPERLINK, OLECMDEXECOPT_DONTPROMPTUSER, sUrl ) ;
	}
	
	command.selectedIndex = 0 ;
	
	objContent.focus();
}

function doFormatBlock(combo)
{
	if (combo.value == null || combo.value == "")
	{
		if (!FCKFormatBlockNames) loadFormatBlockNames() ;
		objContent.ExecCommand(DECMD_SETBLOCKFMT, OLECMDEXECOPT_DODEFAULT, FCKFormatBlockNames[0]);
	}
	else
		objContent.ExecCommand(DECMD_SETBLOCKFMT, OLECMDEXECOPT_DODEFAULT, combo.value);
	
	objContent.focus();
}

function doFontName(combo)
{
	if (combo.value == null || combo.value == "")
	{
		// TODO: Remove font name attribute.
	}
	else
		objContent.ExecCommand(DECMD_SETFONTNAME, OLECMDEXECOPT_DODEFAULT, combo.value);
	
	objContent.focus();
}

function doFontSize(combo)
{
	if (combo.value == null || combo.value == "")
	{
		// TODO: Remove font size attribute (Now it works with size 3. Will it work forever?)
		objContent.ExecCommand(DECMD_SETFONTSIZE, OLECMDEXECOPT_DODEFAULT, 3);
	}
	else
		objContent.ExecCommand(DECMD_SETFONTSIZE, OLECMDEXECOPT_DODEFAULT, parseInt(combo.value));
	
	objContent.focus();
}

function dialogImage()
{
	var html = FCKShowDialog("dialog/fck_image.html", window, 400, 380);
	// The response is the IMG tag HTML
	if (html) insertHtml(html);
	objContent.focus();
}

function breakLine()
{
	var html = "<BR>";
	if (html) insertHtml(html);
	objContent.focus();
}

function dialogTable(searchParentTable)
{
	if (searchParentTable)
	{
		var oRange  = objContent.DOM.selection.createRange() ;
		var oParent = oRange.parentElement() ;
		
		while (oParent && oParent.nodeName != "TABLE")
		{
			oParent = oParent.parentNode ;
		}
		
		if (oParent && oParent.nodeName == "TABLE")
		{
			var oControlRange = objContent.DOM.body.createControlRange();
			oControlRange.add( oParent ) ;
			oControlRange.select() ;
		}
		else
			return ;
	}

	FCKShowDialog("dialog/fck_table.html", window, 400, 310);
	objContent.focus() ;
}

function dialogTableCell()
{
	FCKShowDialog("dialog/fck_tablecell.html", window, 480, 220);
	objContent.focus() ;
}

function dialogLink()
{
	FCKShowDialog("dialog/fck_link.html", window, 400, 190);
	objContent.focus() ;
}

// insertHtml(): Insert HTML at the current document position.
function insertHtml(html)
{
	if (objContent.DOM.selection.type.toLowerCase() != "none")
		objContent.DOM.selection.clear() ;
	objContent.DOM.selection.createRange().pasteHTML(html) ; 
}

function foreColor()
{
	var color = FCKShowDialog("dialog/fck_selcolor.html", "", 370, 240);
	if (color) objContent.ExecCommand(DECMD_SETFORECOLOR,OLECMDEXECOPT_DODEFAULT, color) ;
	objContent.focus();
}

function backColor()
{
	var color = FCKShowDialog("dialog/fck_selcolor.html", "", 370, 240);
	if (color) objContent.ExecCommand(DECMD_SETBACKCOLOR,OLECMDEXECOPT_DODEFAULT, color) ;
	objContent.focus();
}

function insertSpecialChar()
{
	var html = FCKShowDialog("dialog/fck_specialchar.html", window, 400, 250);
	if (html) insertHtml(html) ;
	objContent.focus() ;
}

function insertSmiley()
{
	var html = FCKShowDialog("dialog/fck_smiley.html", window, config.SmileyWindowWidth, config.SmileyWindowHeight) ;
	if (html) insertHtml(html) ;
	objContent.focus() ;
}

function FCKShowDialog(pagePath, args, width, height)
{
	return showModalDialog(pagePath, args, "dialogWidth:" + width + "px;dialogHeight:" + height + "px;help:no;scroll:no;status:no");
}

function about()
{
	FCKShowDialog("dialog/fck_about.html", null, 460, 290);
}

function pastePlainText()
{
	var sText = HTMLEncode( clipboardData.getData("Text") ) ;
	sText = sText.replace(/\n/g,'<BR>') ;
	insertHtml(sText) ;
}

function pasteFromWord()
{
	if (BrowserInfo.IsIE55OrMore)
		cleanAndPaste( GetClipboardHTML() ) ;
	else if ( confirm('This command is available for Internet Explorer version 5.5 or more. Do you want to paste without cleaning?') )
		decCommand(DECMD_PASTE) ;
}

function cleanAndPaste( html )
{
	// Remove Class attributes
	html = html.replace(/<(\w[^>]*) class=([^ |>]*)([^>]*)/gi, "<$1$3") ;
	// Remove Style attributes
	html = html.replace(/<(\w[^>]*) style="([^"]*)"([^>]*)/gi, "<$1$3") ;
	// Remove Lang attributes
	html = html.replace(/<(\w[^>]*) lang=([^ |>]*)([^>]*)/gi, "<$1$3") ;
	// Remove XML elements and declarations
	html = html.replace(/<\\?\??xml[^>]>/gi, "") ;
	// Remove Tags with XML namespace declarations: <o:p></o:p>
	html = html.replace(/<\/?\w+:[^>]*>/gi, "") ;
	// Remove unuseful SPAN tags: "<SPAN>Text</SPAN>" to "Text"
	var re = new RegExp("(?:<SPAN>)(.*?)(?:<\/SPAN>)","gi") ;		// Different because of a IE 5.0 error
	html = html.replace( re, "$1" ) ;
	
	insertHtml( html ) ;
}

function GetClipboardHTML()
{
	var oDiv = document.getElementById("divTemp")
	oDiv.innerHTML = "" ;
	
	var oTextRange = document.body.createTextRange() ;
	oTextRange.moveToElementText(oDiv) ;
	oTextRange.execCommand("Paste") ;
	
	var sData = oDiv.innerHTML ;
	oDiv.innerHTML = "" ;
	
	return sData ;
}

function HTMLEncode(text)
{
	text = text.replace(/"/g, "&quot;") ;
	text = text.replace(/</g, "&lt;") ;
	text = text.replace(/>/g, "&gt;") ;
	text = text.replace(/'/g, "&#146;") ;

	return text ;
}

function showTableBorders()
{
	objContent.ShowBorders = !objContent.ShowBorders ;
	objContent.focus() ;
}

function showDetails()
{
	objContent.ShowDetails = !objContent.ShowDetails ;
	objContent.focus() ;
}

var FCKFormatBlockNames ;

function loadFormatBlockNames()
{
	var oNamesParm = new ActiveXObject("DEGetBlockFmtNamesParam.DEGetBlockFmtNamesParam") ;
	objContent.ExecCommand(DECMD_GETBLOCKFMTNAMES, OLECMDEXECOPT_DODEFAULT, oNamesParm);
	var vbNamesArray = new VBArray(oNamesParm.Names) ;

	FCKFormatBlockNames = vbNamesArray.toArray() ;
}