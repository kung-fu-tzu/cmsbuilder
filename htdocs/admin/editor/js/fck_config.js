var config = new Object() ;
config.BasePath = document.location.pathname.substring(0,document.location.pathname.lastIndexOf('/')+1) ;
config.EditorAreaCSS = config.BasePath + 'css/fck_editorarea.css' ;
config.BaseUrl = document.location.protocol + '//' + document.location.host + '/' ;
config.EnableXHTML = false ;

config.ForcePasteAsPlainText = false ;
config.AutoDetectPasteFromWord = true ;

config.ToolbarImagesPath = config.BasePath + "images/toolbar/" ;

config.ToolbarSets = new Object();

config.ToolbarSets["JLite"] = [
	['EditSource','-','Cut','Copy','Paste','PasteWord', '-', 'Undo','Redo', '-', 'JustifyLeft','JustifyCenter','JustifyRight','JustifyFull', '-', 'InsertOrderedList','InsertUnorderedList','BreakLine','Outdent','Indent'],
        ['Link','Subscript','Superscript','-', 'Bold','Italic','Underline','RemoveFormat','FontSize','-', 'TextColor','BGColor','-','Image','Table', 'Rule', 'SpecialChar']
];

config.ToolbarSets["Source"] = [
	['EditSource']
];

config.StyleNames  = 'Стиль текста;Заметка (мелкий шрифт);Заметка красным цветом;Заметка синим цветом;Красный текст;Серый цвет;Синий цвет';
config.StyleValues = ';description;descriptionred;descriptionblue;red;gray;blue';

config.ToolbarFontNames = ';Arial;Comic Sans MS;Courier New;Tahoma;Times New Roman;Verdana' ;

config.ImageBrowser = false;
// Custom Page URL
config.ImageBrowserURL = config.BasePath + "filemanager/browse/image_browser/browse.php" ;
//config.ImageBrowserURL = config.BasePath + "filemanager/browse/sample_php/browse.php" ;
// Image browsing window sizes
config.ImageBrowserWindowWidth  = 400 ;
config.ImageBrowserWindowHeight = 300 ;

//##
//## Image Upload
//##
config.ImageUpload = false;
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
config.LinkBrowser = false;
// Custom Page URL
config.LinkBrowserURL = config.BasePath + "filemanager/browse/file_browser/browse.php" ;
// Link browsing window sizes
config.LinkBrowserWindowWidth	= 400 ;
config.LinkBrowserWindowHeight	= 250 ;

//##
//## Link Upload
//##
config.LinkUpload = false ;
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
//config.SmileyImages = ["aiua.gif","ak.gif","alien.gif","alien2.gif","angry.gif","angry1.gif","apophys.gif","assjani.gif","asthanos.gif","bazuzeus.gif","beaute.gif","bigsmile.gif","blush.gif","boid.gif","bonk.gif","bored.gif","borg.gif","capo.gif","confused.gif","cool.gif","crazy.gif","cwm14.gif","demis_roussos.gif","devil.gif","devil2.gif","double0smile.gif","eek3.gif","eltaf.gif","gele.gif","halm.gif","happy.gif","icon12.gif","icon23.gif","icon26.gif","icon_angel.gif","icon_bandit.gif","icon_bravo.gif","icon_clown.gif","jesors.gif","jesors1.gif","lol3.gif","love.gif","mad.gif","megaphone.gif","mmm.gif","music.gif","notify.gif","nuts.gif","obanon.gif","ouaip.gif","pleure.gif","plugin.gif","question.gif","question2.gif","rasta2.gif","rastapop.gif","rosebud.gif","sad.gif","sad2.gif","shocked.gif","sick.gif","sick2.gif","slaap.gif","sleep.gif","smile.gif","smiley_peur.gif","sors.gif","sovxx.gif","spamafote.gif","tap67.gif","thumbdown.gif","thumbup.gif","tigi.gif","toad666.gif","tongue.gif","tuffgong.gif","urge
//man.gif","vanadium.gif","wink.gif","worship.gif","wouaf.gif","wow.gif","xp1700.gif","yltype.gif","yopyopyop.gif","youpi.gif","zoor.gif"] ;
//config.SmileyPath	= config.BasePath + "images/smiley/msn/" ;
//config.SmileyImages	= ["regular_smile.gif","sad_smile.gif","wink_smile.gif","teeth_smile.gif","confused_smile.gif","tounge_smile.gif","embaressed_smile.gif","omg_smile.gif","whatchutalkingabout_smile.gif","angry_smile.gif","angel_smile.gif","shades_smile.gif","devil_smile.gif","cry_smile.gif","lightbulb.gif","thumbs_down.gif","thumbs_up.gif","heart.gif","broken_heart.gif","kiss.gif","envelope.gif"] ;
//config.SmileyColumns = 7 ;
//config.SmileyWindowWidth	= 500 ;
//config.SmileyWindowHeight	= 200 ;