
function FormatText(command, option){
	
  	frames.message.document.execCommand(command, false, option);
  	frames.message.focus();
}

function AddImage(){	
	window.open('filemanager.php', 'filemanager', 'scrollbars=yes,width=500,height=400,left=100,top=100');
}

function ShowHTML(){
document.all.im2.style.display = '';
document.all.im1.style.display = 'none';
NewHTML = frames.message.document.body.innerHTML;
document.all.Frm.style.display = 'none';
Add.r_text.value = NewHTML;
Add.r_text.style.display = 'block';
HTMLmode = 1;
}

function ShowNormal(){
document.all.im1.style.display = '';
document.all.im2.style.display = 'none';
NewHTML = Add.r_text.value;
Add.r_text.style.display = 'none';
frames.message.document.body.innerHTML = NewHTML;
document.all.Frm.style.display = 'block';
HTMLmode = 0;
}

function PreSubmit() {
if (HTMLmode==0) {
	ShowHTML();
}
}

function a(obj){
obj.style.border = "0";
}

function b(obj){
obj.style.border = "1px Solid Gray";
}

function UPfile(){
document.all.MenuFile.style.display='';
HiddenS();
}

function DOWNfile(){
document.all.MenuFile.style.display='none';
ShowS();
}

function HiddenS(){
Add.Heading.style.visibility='hidden';
Add.selectFont.style.visibility='hidden';
}

function ShowS(){
Add.Heading.style.visibility='visible';
Add.selectFont.style.visibility='visible';
}

function Preview(){
	
	var TXT = frames.message.document.body.innerHTML;
	var board=window.open("","Preview"); 
	board.document.open(); 
	board.document.write("<html>"); 
	board.document.write("<head><title>Preview</title></head>"); 
	board.document.write(TXT); 
	board.document.write("</body>"); 
	board.document.write("</html>"); 
	board.document.close();

	return board;
}

function Save(){
	
	board = Preview();
  	board.document.execCommand('SaveAs');
	board.window.close();
}

function PrintPage(){
	
	board = Preview();
  	board.document.execCommand('Print');
	board.window.close();
}

	function AddHTML(AnCode) {

	var range = frames.message.document.selection.createRange();
	range.pasteHTML(AnCode);
	range.select();
	range.execCommand();

 		frames.message.focus();
	}













