
function doDel(){

	return window.confirm('Удалить?');
}

function EML_href(nspace){

	var href = event.srcElement.getAttribute("href");
	
	var ser = href.split("?");
	var cook = ser[1];

	var ar = cook.split("=");
	
	cook = ar.join("&");

	document.cookie = "EML_" + nspace + "=" + cook;

	location.href = href;

	return false;
}
