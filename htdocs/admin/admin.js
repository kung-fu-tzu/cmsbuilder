

function ShowHide(obj,dot){

	if(obj.style.display == "none"){
		
		obj.style.display = "block";
		dot.src = "minus.gif";
		document.cookie = obj.id + " = s&1";
	}else{
		obj.style.display = "none";
		dot.src = "plus.gif";
		document.cookie = obj.id + " = s&0";
	}

}

function ShowMe(obj,dot){

	if(obj){
		
		obj.style.display = "block";
		dot.src = "minus.gif";
		document.cookie = obj.id + " = s&1";
	}
}

function doDel(){

	return window.confirm('Удалить?');
}


is_draging = 0;
drag_obj = null;
drag_dx = 0;
drag_dy = 0;

function StartDrag(obj){
	
	drag_obj = obj;
	is_draging = 1;
	
	drag_obj.style.position = "absolute";
	drag_obj.style.zIndex = 200;
	
	mx = event.x + document.body.scrollLeft - 2;
	my = event.y + document.body.scrollTop - 2;
	drag_dx = obj.getBoundingClientRect().left + document.body.scrollLeft - 2 - mx;
	drag_dy = obj.getBoundingClientRect().top + document.body.scrollTop - 2 - my;
	
	return false;
}



function SelectLeft(obj){
	
	//alert("select("+obj.tagName+")");
	
	if(parent.prev_left_obj){
		
		parent.prev_left_obj.style.color = "";
		parent.prev_left_obj.style.backgroundColor = "";
	}
	
	if(obj){
		
		obj.style.backgroundColor = "#FBB57B";
		obj.style.color = "#000000";
	}

	parent.prev_left_obj = obj;
}

function StopDrag(obj){
	
	if(drag_obj != obj){
		
		window.status = "DO: Moving "+drag_obj.id+" to "+obj.id;
	}
	
	drag_obj.style.position = "";
	
	drag_obj = null;
	is_draging = 0;
	
	obj.style.zIndex = 250;
	
	return false;
}

function MMove(){
	
	if( !is_draging || drag_obj == null) return;
	
	x = event.x + document.body.scrollLeft - 2;
	y = event.y + document.body.scrollTop - 2;
		
	drag_obj.style.posLeft = x + drag_dx;
	drag_obj.style.posTop = y + drag_dy;
	
}

function OnOver(obj){
	
	if( !is_draging || drag_obj == null) return;
	if( drag_obj == obj ) return;
	
	obj.style.backgroundColor = "#ffff00";
	
	window.status = "Move "+drag_obj.id+" to "+obj.id;

}

function OnOut(obj){
	
	if( !is_draging || drag_obj == null) return;
	if( drag_obj == obj ) return;
	
	obj.style.backgroundColor = "#000000";
	
	window.status = "";

}

document.onmousemove = MMove;



