<?php
        require_once("../../config.php");



?>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<HTML>
	<HEAD>
		<TITLE>Загрузка файла</TITLE>
		<LINK rel="stylesheet" type="text/css" href="/admin/css/styles.css">
	</HEAD>
	<BODY><form>
		<TABLE eight="100%" width="100%">
			<TR>
				<TD align=center valign=middle><B>
					Идет загрузка файла...
<font color='red'><BR><BR>
<?php 

if (file_exists($UPLOAD_BASE_DIR.$HTTP_POST_FILES['FCKeditor_File']['name'])) {
	echo "Ошибка : файл ".$HTTP_POST_FILES['FCKeditor_File']['name']." уже существует...";
	echo '<BR><BR><INPUT type="button" value=" Cancel " onclick="window.close()">';
} else {
	if (is_uploaded_file($HTTP_POST_FILES['FCKeditor_File']['tmp_name'])) {
		$savefile = $UPLOAD_BASE_DIR.$HTTP_POST_FILES['FCKeditor_File']['name'];

		if (move_uploaded_file($HTTP_POST_FILES['FCKeditor_File']['tmp_name'], $savefile)) {
			chmod($savefile, 0666);
			?>
		<SCRIPT language=javascript>window.opener.setImage('<?php echo $UPLOAD_BASE_URL.$HTTP_POST_FILES['FCKeditor_File']['name']; ?>') ; window.close();</SCRIPT>";
		<?php
		}
	} else {
		echo "Ошибка : ";
		switch($HTTP_POST_FILES['FCKeditor_File']['error']) {
			case 0: //no error; possible file attack!
				echo "Возникла проблема при передаче файла.";
				break;
			case 1: //uploaded file exceeds the upload_max_filesize directive in php.ini
				echo "Размер файла превышает максимально допустимый.";
				break;
			case 2: //uploaded file exceeds the MAX_FILE_SIZE directive that was specified in the html form
				echo "Размер файла превышает максимально допустимый.";
				break;
			case 3: //uploaded file was only partially uploaded
				echo "Файл был передан с частичными повреждениями.";
				break;
			case 4: //no file was uploaded
				echo "Изображение не выбрано.";
				break;
			default: //a default error, just in case!  :)
				echo "Возникла проблема при передаче файла.";
				break;
		}
	}
	echo '<BR><BR><INPUT type="image" src="/admin/img/button-cancel.gif" onclick="window.close()">';
} ?>
				</font></B></TD>
			</TR>
		</TABLE>
	</form></BODY>
</HTML>
