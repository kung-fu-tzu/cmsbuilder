
function Tree_div_it(){
	
	if(!CMS_HaveParent()){
		document.write(
	'	<table cellSpacing="0" cellPadding="0" width="100%" height="100%"><tr height="39"><td>'+
	
	'	<table cellSpacing="0" cellPadding="0" width="100%" border="0">'+
	'	<tr height="100%">'+
	'		<td width="16"><img id="id_show" style="DISPLAY: none" src="img/show.gif" onclick="ShowLeft()"></td>'+
	'		<td><b>Активный элемент:</b><br><div id="tree_div_it">Элемент не выбран</div></td>'+
	'		<td width="132" align="right">'+shtoolbox.innerText+'</td>'+
	'		<td width="16"></td>'+
	'	</tr>'+
	'	<tr height="5"><td></td></tr>'+
	'	<tr><td colspan="4" class="red_hr"></td></tr>'+
	'	</table>'+
	
	'	</td></tr><tr><td valign="top">');
	}
	
}

function Status_div_it(){
	
	if(!CMS_HaveParent()){
		document.write(
	'	</td></tr><tr height="39"><td>'+
	
	'	<table cellSpacing="0" cellPadding="0" width="100%" border="0">'+
	'	<tr height="100%">'+
	'		<td width="16"></td>'+
	'		<td><a target="admin_right" href="credits.html"><font class="red_font">О системе администрирования...</font></a></td>'+
	'		<td width="132" align="right"><font class="red_font">'+shbottombox.innerText+'</font></td>'+
	'		<td width="16"></td>'+
	'	</tr>'+
	'	<tr height="5"><td></td></tr>'+
	'	</table>'+
	
	'	</table>');
	}
	
}

function ShowHide(obj,dot){
	
	if(obj.style.display == "none"){
		
		obj.style.display = "block";
		dot.src = "img/minus.gif";
		document.cookie = obj.id + " = s&1";
	}else{
		obj.style.display = "none";
		dot.src = "img/plus.gif";
		document.cookie = obj.id + " = s&0";
	}
	
}

function HideLeft(){
	
	id_left_td.style.display = "none";
	id_left_border.style.display = "none";
	id_show.style.display = "block";
}

function ShowLeft(){
	
	id_left_td.style.display = "block";
	id_left_border.style.display = "block";
	id_show.style.display = "none";
}

function doDel(){
	
	return window.confirm('Удалить?');
}

function SelectMod(obj){
	
	if(obj) obj.className = 'selected_item';
}

var prev_obj;

function CMS_SelectLO(obj){
	
	if(window.name != 'admin_left') return false;
	if(!document.all[obj]) return false;
	
	if(document.all[prev_obj]) document.all[prev_obj].className = '';
	
	document.all[obj].className = 'selected_item';
	
	prev_obj = obj;
	
	return true;
}
document.CMS_SelectLO = CMS_SelectLO;

function CMS_ShowMe(url){
	
	if(document.all['dbi_'+url]){
		document.all['dbi_'+url].style.display = "block";
		document.cookie = document.all['dbi_'+url].id + " = s&1";
	}
	
	if(document.all['dbdot_'+url]){
		document.all['dbdot_'+url].src = "img/minus.gif";
	}
}

function ShowDetails(){
	
	hide1.style.display = 'none';
	
	show1.style.display = 'block';
	show2.style.display = 'block';
	show3.style.display = 'block';
	show4.style.display = 'block';
	show5.style.display = 'block';
}

function CMS_HaveParent(){
	
	return parent.document != document;
}

//  Drag&Drop  //////////////////////////////////////////////////////////

var f_drag_mouse_up;
var f_drag_mouse_move;
var drag_obj = null;
var drag_line_n1;
var drag_line_n2;
var drag_num;
var drag_start_num;
var drag_href_url;


function DnD_Line_OnMouseOver(num,obj){
	if(obj.className != "drag_line_droped") obj.className = "drag_line_on";
	drag_num = num;
}

function DnD_Line_OnMouseOut(num,obj){
	if(obj.className != "drag_line_droped") obj.className = "drag_line";
	drag_num = 0;
}


function DnD_OnMouseUp(){
	
	document.onmouseup = f_drag_mouse_up;
	document.onmousemove = f_drag_mouse_move;
	
	if(!drag_num){
		for(i=drag_line_n1;i<=drag_line_n2;i++)
			document.all['drag_line_'+i].style.display = 'none';
		drag_obj.style.position = "";
	}
	
	if(drag_num){
		document.all['drag_line_'+drag_num].className = "drag_line_droped";
		new_href = 'right.ehtml?url=' + drag_href_url + '&act=move&enum=' + drag_start_num + '&nnum=' + drag_num;
		//alert(new_href);
		document.location.href = new_href;
	}
	
	drag_obj = null;
}

function DnD_OnMouseMove(){
	
	if(!drag_obj) return;
	
	x = event.x + document.body.scrollLeft + 20;
	y = event.y + document.body.scrollTop + 2;
	
	drag_obj.style.posLeft = x;
	drag_obj.style.posTop = y;
}

function OnDragStart(obj){
	
	drag_obj = obj;
	
	drag_obj.style.position = "absolute";
	drag_obj.style.zIndex = 200;
	
	f_drag_mouse_up = document.onmouseup;
	document.onmouseup = DnD_OnMouseUp;
	
	f_drag_mouse_move = document.onmousemove;
	document.onmousemove = DnD_OnMouseMove;
	
	DnD_OnMouseMove();
	
	for(i=drag_line_n1;i<=drag_line_n2;i++)
		document.all['drag_line_'+i].style.display = 'block';
	
	return false;
}

