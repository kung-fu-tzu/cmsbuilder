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

if(is_file($IMAGES_BASE_DIR."/".$_GET["file"]))
{
	unlink($IMAGES_BASE_DIR."/".$_GET["file"]);
}

// ================================================================

?>
<html>
<body>
<script language=javascript>
window.close();
</script>
</body>
</html>