<?php

// ================================================================

require_once("../../config.php");

// ================================================================


// ================================================================

$folders = explode("/", $_GET["folder"]);
for($i = 0; $i < count($folders); $i++)
{
	if($folders[$i] != "")
	{
		$IMAGES_BASE_DIR .= $folders[$i]."/";
		if(!file_exists($IMAGES_BASE_DIR) || !is_dir($IMAGES_BASE_DIR))
		{
			mkdir($IMAGES_BASE_DIR, 0777);
		}
	}
}

// ================================================================

$IMAGES_BASE_URL = str_replace($GLOBALS["DOCUMENT_ROOT"], "", $IMAGES_BASE_DIR);

// ================================================================

function walk_dir($path)
{
	if($dir = opendir($path))
	{
		while(false !== ($file = readdir($dir)))
		{
			if($file[0] == ".")
			{
				continue;
			}
			if(is_dir($path."/".$file))
			{
				$retval = array_merge($retval, walk_dir($path."/".$file));
			}
			else if(is_file($path."/".$file))
			{
				$retval[] = $path."/".$file;
			}
		}
		closedir($dir);
	}
	return $retval;
}

// ================================================================

function CheckImgExt($filename)
{
	$img_exts = array("gif", "jpg", "jpeg", "png");
	foreach($img_exts as $this_ext)
	{
		if(preg_match("/\.$this_ext$/", $filename))
		{
			return true;
		}
	}
	return false;
}

// ================================================================

$i = 0;
if(is_array(walk_dir($IMAGES_BASE_DIR)))
{
	foreach(walk_dir($IMAGES_BASE_DIR) as $file)
	{
		$file = preg_replace("#//+#", '/', $file);
		$IMAGES_BASE_DIR = preg_replace("#//+#", '/', $IMAGES_BASE_DIR);
		$file = preg_replace("#$IMAGES_BASE_DIR#", '', $file);
		if(CheckImgExt(strtolower($file)))
		{
			$html_img_lst[$i++] = $file;
		}
	}
}

// ================================================================

?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<html>
<head>
<title> Обзор сервера </title>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1251">
<link rel="stylesheet" type="text/css" href="../../../css/fck_dialog.css">
<script language="javascript">
var sImagesPath  = "<?php echo $IMAGES_BASE_URL; ?>";
var sActiveImage = "" ;
function ok()
{	
	window.setImage(sActiveImage);
	window.close();
}
function getImage(imageName)
{
	sActiveImage = sImagesPath + imageName;
	imgPreview.src = sActiveImage;
}
</script>
</head>
<body text=#000000 link=#336699 alink=#336699 vlink=#336699 marginwidth=0 marginheight=0 leftmargin=0 topmargin=0 rightmargin=0 bottommargin=0>

<table border=0 cellspacing=0 cellpadding=0 width=100% height=100% class=dlg>
<tr height=100%>
 <td>
  <table border=0 cellspacing=0 cellpadding=0 width=100% height=100%>
  <tr valign=top>
   <td width=50%>
    <table border=0 cellspacing=10 cellpadding=0 width=100% height=100%>
    <tr><td width="100%">Файл:</td></tr>
    <tr height="100%"><td><div class="ImagePreviewArea">
     <table border=0 cellspacing=5 cellpadding=0 width=100%>
<?php

// ================================================================

for($i = 0; $i < count($html_img_lst); $i++)
{
	echo "<tr><td width=100%><a href=\"javascript:getImage(escape(escape('".$html_img_lst[$i]."')))\">".urldecode($html_img_lst[$i])."</a></td><td><a href='delete.php?folder=".$_GET["folder"]."&file=".urlencode($html_img_lst[$i])."' onClick=\"return window.confirm('Вы уверены?')\">удалить</a></td></tr>";
}

// ================================================================

?>
     </table>
    </div></td></tr>
    </table>
   </td>
   <td width=50%>
    <table border=0 cellspacing=10 cellpadding=0 width=100% height=100%>
    <tr><td width="100%">Предпросмотр:</td></tr>
    <tr><td height="100%" align="center" valign="middle"><div class="ImagePreviewArea"><img id="imgPreview" border=0 src="Выберете картинку"></div></td></tr>
    </table>
   </td>
  </tr>
  </table>
 </td>
</tr>
<tr>
 <td align=center>
  <table border=0 cellspacing=10 cellpadding=0><tr>
  <td><input type=button value="OK" onclick="ok();" style="width:80px;"></td>
  <td><input type=button value="Cancel" onclick="window.close();" style="width:80px;"></td>
  </tr></table>
 </td>
</tr>
</table>

</body>
</html>