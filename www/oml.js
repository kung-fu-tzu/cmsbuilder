

function OML_href(nspace){

	var href = event.srcElement.getAttribute("href");
	
	var ser = href.split("?");
	var cook = ser[1];

	var ar = cook.split("=");
	
	cook = ar.join("&");

	document.cookie = "OML_" + nspace + "=" + cook;

	location.href = ser[0];

	return false;
}
