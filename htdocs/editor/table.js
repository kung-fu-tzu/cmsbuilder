function InsertTable() {

	var newWindowFeatures="dependent=1,Height=230,Width=300"; 
	var board=window.open("","InsertTable",newWindowFeatures); 
	board.document.open(); 
	board.document.write("<html>"); 
	board.document.write("<head><title>Вставка таблицы</title></head>"); 
	board.document.write("<script language=Javascript>function AddTbl() {	TD = document.all.Stolbov.value;	CTD = '';	for (i=0;i<TD;i++) {	CTD = CTD+'<td> </td>';	}; TR = document.all.Strok.value;	CTR = '';	for (i=0;i<TR;i++) {	CTR = CTR+'<tr>'+CTD+'</tr>';	}; 	AnCode = '<table width='+document.all.Shirina.value+' cellpadding='+document.all.Cellpadding.value+' cellspacing='+document.all.Cellspacing.value+' border='+document.all.Border.value+' bgcolor='+document.all.Color.value+'>'+CTR+'</table>';	var range = window.opener.frames.message.document.selection.createRange();	range.pasteHTML(AnCode);	range.select();	range.execCommand();		window.close();	}</script>"); 
	board.document.write("<body topmargin=0 leftmargin=0>"); 
	board.document.write("<table width=100%><tr><td>Ширина таблицы</td><td><input size=15 name=Shirina value='100%'></td>	</tr>	<tr>		<td>Количество строк</td>		<td><input size=15 name=Strok value='1'></td>	</tr>	<tr>		<td>Количество столбцов</td>		<td><input size=15 name=Stolbov value='1'></td>	</tr>	<tr>		<td>Ширина рамки</td>		<td><input size=15 name=Border value='1'></td>	</tr>	<tr>		<td>Cellpadding</td>		<td><input size=15 name=Cellpadding value='2'></td>	</tr>	<tr>		<td>Cellspacing</td>		<td><input size=15 name=Cellspacing value='1'></td>	</tr>	<tr>		<td>Цвет фона #</td>		<td><input size=15 name=Color value='White' maxlength=6></td></tr></table><center><input type=button value=Вставить OnClick=\"AddTbl()\"></center>"); 
	board.document.write("</body>"); 
	board.document.write("</html>"); 
	board.document.close();

}