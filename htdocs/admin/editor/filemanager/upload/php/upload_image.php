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
		$UPLOAD_BASE_URL .= $folders[$i]."/";
		$UPLOAD_BASE_DIR .= $folders[$i]."/";
		if(!file_exists($UPLOAD_BASE_DIR) || !is_dir($UPLOAD_BASE_DIR))
		{
			mkdir($UPLOAD_BASE_DIR, 0777);
		}
	}
}

// ================================================================

?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<html>
<head>
<title>�������� �����</title>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1251">
<link rel="stylesheet" type="text/css" href="../../../css/fck_dialog.css">
</head>
<body text=#000000 link=#336699 alink=#336699 vlink=#336699 marginwidth=0 marginheight=0 leftmargin=0 topmargin=0 rightmargin=0 bottommargin=0>

<table border=0 cellspacing=0 cellpadding=0 width=100% height=100% class=dlg>
<tr>
 <td height=100% width=100% align=center valign=middle>
���� �������� �����&#133;<br><br>
<font color=red>
<?php 

// ================================================================

$_FILES["FCKeditor_File"]["name"] = urlencode(strtolower($_FILES["FCKeditor_File"]["name"]));

if(file_exists($UPLOAD_BASE_DIR.$_FILES["FCKeditor_File"]["name"]))
{

// ================================================================

?>
������: ���� "<?php echo $_FILES["FCKeditor_File"]["name"]; ?>" ���&nbsp;����������&#133;<br><br>
<input type=button value="Cancel" onclick="window.close();">
<?php

// ================================================================

}
else
{
	if(is_uploaded_file($_FILES["FCKeditor_File"]["tmp_name"]))
	{
		$savefile = $UPLOAD_BASE_DIR.$_FILES["FCKeditor_File"]["name"];
		if(move_uploaded_file($_FILES["FCKeditor_File"]["tmp_name"], $savefile))
		{
			chmod($savefile, 0777);
?>
<script language=javascript>
window.opener.setImage(escape('<?php echo $UPLOAD_BASE_URL.$_FILES["FCKeditor_File"]["name"]; ?>'));
window.close();
</script>
<?php
		}
	}
	else
	{
?>
������:
<?php
		switch($_FILES["FCKeditor_File"]["error"])
		{
			case 0: // no error; possible file attack!
				echo "�������� �������� ���&nbsp;�������� �����.";
				break;
			case 1: // uploaded file exceeds the upload_max_filesize directive in php.ini
				echo "������ ����� ��������� ����������� ����������.";
				break;
			case 2: // uploaded file exceeds the MAX_FILE_SIZE directive that was specified in the html form
				echo "������ ����� ��������� ����������� ����������.";
				break;
			case 3: // uploaded file was only partially uploaded
				echo "���� ��� ������� �&nbsp;���������� �������������.";
				break;
			case 4: // no file was uploaded
				echo "����������� ��&nbsp;�������.";
				break;
			default: // a default error, just in case! :)
				echo "�������� �������� ���&nbsp;�������� �����.";
				break;
		}
?>
<br><br>
<input type=button value="Cancel" onclick="window.close();">
<?php
	}

// ================================================================

}

// ================================================================

?>
</font>
 </td>
</tr></table>

</body>
</html>