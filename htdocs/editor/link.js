	function OpenLink() {
	var newWindowFeatures="dependent=1,Height=120,Width=250"; 
	var board=window.open("","InsertLinks",newWindowFeatures); 
	board.document.open(); 
	board.document.write("<html>"); 
	board.document.write("<head><title>Вставка гиперссылки</title></head>"); 
	board.document.write("<script language=Javascript>function AddLink() {	AnCode = '<a href='+document.all.Path.value+document.all.Target.value+'>'+window.opener.frames.message.document.selection.createRange().text+'</a>';	var range = window.opener.frames.message.document.selection.createRange();	range.pasteHTML(AnCode);	range.select();	range.execCommand();		window.close();	}</script>"); 
	board.document.write("<body topmargin=0 leftmargin=0>"); 
	board.document.write("<br><br><table width=100%><tr><td>URL:</td><td><input size=20 name=Path value=http://></td></tr><tr><td>Открытие:</td><td><select name=Target><option value=' target=_blank'>В новом окне<option value=' target=_self' selected>В этом же окне</select></td></tr></table><center><input type=button value=Вставить OnClick=\"AddLink()\"></center>"); 
	board.document.write("</body>"); 
	board.document.write("</html>"); 
	board.document.close();

	}