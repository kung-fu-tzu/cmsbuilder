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
 * fck_config.js: Holds all configurations.
 *
 * Authors:
 *   Frederico Caldeira Knabben (fckeditor@fredck.com)
 */

//##
//## "config" is the global object that holds all configurations
//##
var config = new Object() ;

//##
//## Editor Base Path
//##
config.BasePath = document.location.pathname.substring(0,document.location.pathname.lastIndexOf('/')+1) ;

//##
//## Style File to be used the the editor
//##
config.EditorAreaCSS = config.BasePath + 'css/fck_editorarea.css' ;

//##
//## Base URL used to set relative links
//##
config.BaseUrl = document.location.protocol + '//' + document.location.host + '/' ;

//##
//## Enable XHTML support (slower)
//##
config.EnableXHTML = false ;

//##
//## Cut and Paste options
//##
config.ForcePasteAsPlainText = false ;
config.AutoDetectPasteFromWord = true ;

//##
//## Sets the toolbar icons path
//##
config.ToolbarImagesPath = config.BasePath + "images/toolbar/" ;

//##
//## Toolbar Buttons Sets
//##
config.ToolbarSets = new Object() ;
config.ToolbarSets["JLite"] = [
	['EditSource','-','Cut','Copy','Paste','PasteWord', '-', 'Undo','Redo', '-', 'JustifyLeft','JustifyCenter','JustifyRight','JustifyFull', '-', 'InsertOrderedList','InsertUnorderedList'],
        ['Outdent','Indent','Link','Subscript','Superscript','-', 'Bold','Italic', 'Underline', '-', 'TextColor', '-','Image','Table', 'Rule', 'SpecialChar', 'PagesList']
] ;
config.ToolbarSets["CMS1.0"] = [
	['EditSource','-','Cut','Copy','Paste','PasteWord', '-', 'Find', 'Undo','Redo', '-', 'JustifyLeft','JustifyCenter','JustifyRight','JustifyFull', '-', 'InsertOrderedList','InsertUnorderedList','Outdent','Indent','Link','RemoveLink'] ,
	['Subscript','Superscript','-', 'Bold','Italic', 'Underline', 'BreakLine', '-', 'TextColor', '-','RemoveFormat', '-','Image','Table', 'Rule', 'SpecialChar', 'PagesList']
] ;

config.ToolbarSets["CMS1.1"] = [
	['EditSource','-','Cut','Copy','Paste','PasteText','Find','Undo','Redo','-','SelectAll','RemoveFormat','-','InsertOrderedList','InsertUnorderedList','-','Outdent','Indent','-','Link','RemoveLink','-','Image','Rule','SpecialChar','ShowTableBorders'] ,
	['Bold','Italic','-','Subscript','Superscript','-','JustifyLeft','JustifyCenter','JustifyRight','JustifyFull','-','FontStyle','-','PagesList',]
] ;

config.ToolbarSets["Default"] = [
	['EditSource','-','Cut','Copy','Paste','PasteText','PasteWord','-','Find','-','Undo','Redo','-','SelectAll','RemoveFormat','-','Link','RemoveLink','-','Image','Table','Rule','SpecialChar'] ,
	['Bold','Italic','Underline','StrikeThrough','-','Subscript','Superscript','-','JustifyLeft','JustifyCenter','JustifyRight','JustifyFull','-','InsertOrderedList','InsertUnorderedList','-','Outdent','Indent','-','ShowTableBorders','ShowDetails','-','TextColor','BGColor'] ,
	['FontStyle','-','FontFormat','-','Font','-','FontSize']
] ;

config.ToolbarSets["Source"] = [
	['EditSource']
] ;

config.ToolbarSets["Accessibility"] = [
	['EditSource','-','Cut','Copy','Paste','-','SelectAll','RemoveFormat','-','Link','RemoveLink','-','Image','Rule','-','About'] ,
	['FontStyle','-','Bold','Italic','Underline','-','InsertOrderedList','InsertUnorderedList','-','Undo','Redo']
] ;

config.ToolbarSets["Basic"] = [
	['Bold','Italic','-','InsertOrderedList','InsertUnorderedList','-','Link','RemoveLink','-','About']
] ;

//##
//## Style Names
//##
config.StyleNames  = 'Стиль текста;Заметка (мелкий шрифт);Заметка красным цветом;Заметка синим цветом;Красный текст;Серый цвет;Синий цвет';
config.StyleValues = ';description;descriptionred;descriptionblue;red;gray;blue';

//##
//## Page Names
//##

//## <?eml admin::page_hrefs(); ?>

//##
//## Font Names
//##
config.ToolbarFontNames = ';Arial;Comic Sans MS;Courier New;Tahoma;Times New Roman;Verdana' ;

//##
//## Image Browsing
//##
config.ImageBrowser = true ;
// Custom Page URL
config.ImageBrowserURL = config.BasePath + "filemanager/browse/image_browser/browse.php" ;
//config.ImageBrowserURL = config.BasePath + "filemanager/browse/sample_php/browse.php" ;
// Image browsing window sizes
config.ImageBrowserWindowWidth  = 400 ;
config.ImageBrowserWindowHeight = 300 ;

//##
//## Image Upload
//##
config.ImageUpload = true ;
// Page that effectivelly upload the image.
//config.ImageUploadURL = config.BasePath + "filemanager/upload/aspx/upload.aspx" ;
//config.ImageUploadURL = config.BasePath + "filemanager/upload/cfm/upload.cfm" ;
config.ImageUploadURL = config.BasePath + "filemanager/upload/php/upload_image.php" ;
// Image upload window sizes
config.ImageUploadWindowWidth	= 300 ;
config.ImageUploadWindowHeight	= 150 ;
config.ImageUploadAllowedExtensions = ".gif .jpg .jpeg .png" ;

//##
//## Link Browsing
//##
config.LinkBrowser = true ;
// Custom Page URL
config.LinkBrowserURL = config.BasePath + "filemanager/browse/file_browser/browse.php" ;
// Link browsing window sizes
config.LinkBrowserWindowWidth	= 400 ;
config.LinkBrowserWindowHeight	= 250 ;

//##
//## Link Upload
//##
config.LinkUpload = true ;
// Page that effectivelly upload the Link file.
config.LinkUploadURL = config.BasePath + "filemanager/upload/php/upload_file.php" ;
// Link upload window sizes
config.LinkUploadWindowWidth	= 300 ;
config.LinkUploadWindowHeight	= 150 ;
config.LinkUploadAllowedExtensions	= "*" ;		// * or empty for all
config.LinkUploadDeniedExtensions	= ".asp .php .aspx .js .cfm .dll" ;	// empty for no one

//##
//## Smiley Dialog
//##
//config.SmileyPath = config.BasePath + "images/smiley/fun/" ;
//config.SmileyImages = ["aiua.gif","ak.gif","alien.gif","alien2.gif","angry.gif","angry1.gif","apophys.gif","assjani.gif","asthanos.gif","bazuzeus.gif","beaute.gif","bigsmile.gif","blush.gif","boid.gif","bonk.gif","bored.gif","borg.gif","capo.gif","confused.gif","cool.gif","crazy.gif","cwm14.gif","demis_roussos.gif","devil.gif","devil2.gif","double0smile.gif","eek3.gif","eltaf.gif","gele.gif","halm.gif","happy.gif","icon12.gif","icon23.gif","icon26.gif","icon_angel.gif","icon_bandit.gif","icon_bravo.gif","icon_clown.gif","jesors.gif","jesors1.gif","lol3.gif","love.gif","mad.gif","megaphone.gif","mmm.gif","music.gif","notify.gif","nuts.gif","obanon.gif","ouaip.gif","pleure.gif","plugin.gif","question.gif","question2.gif","rasta2.gif","rastapop.gif","rosebud.gif","sad.gif","sad2.gif","shocked.gif","sick.gif","sick2.gif","slaap.gif","sleep.gif","smile.gif","smiley_peur.gif","sors.gif","sovxx.gif","spamafote.gif","tap67.gif","thumbdown.gif","thumbup.gif","tigi.gif","toad666.gif","tongue.gif","tuffgong.gif","urgeman.gif","vanadium.gif","wink.gif","worship.gif","wouaf.gif","wow.gif","xp1700.gif","yltype.gif","yopyopyop.gif","youpi.gif","zoor.gif"] ;
config.SmileyPath	= config.BasePath + "images/smiley/msn/" ;
config.SmileyImages	= ["regular_smile.gif","sad_smile.gif","wink_smile.gif","teeth_smile.gif","confused_smile.gif","tounge_smile.gif","embaressed_smile.gif","omg_smile.gif","whatchutalkingabout_smile.gif","angry_smile.gif","angel_smile.gif","shades_smile.gif","devil_smile.gif","cry_smile.gif","lightbulb.gif","thumbs_down.gif","thumbs_up.gif","heart.gif","broken_heart.gif","kiss.gif","envelope.gif"] ;
config.SmileyColumns = 7 ;
config.SmileyWindowWidth	= 500 ;
config.SmileyWindowHeight	= 200 ;