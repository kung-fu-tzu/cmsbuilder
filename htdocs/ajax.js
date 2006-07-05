
//———————————————————— Удобная обертка для XMLHttpRequest ——————————————————————

function HttpRequest()
{
	var http_request = false;

	if(window.XMLHttpRequest) // Mozilla, Safari, ...
	{
		http_request = new XMLHttpRequest();
		if(http_request.overrideMimeType) http_request.overrideMimeType('text/xml');
	}
	else if(window.ActiveXObject) // IE
	{
		try
		{
			http_request = new ActiveXObject("Msxml2.XMLHTTP");
		}
		catch(T)
		{
			try
			{
				http_request = new ActiveXObject("Microsoft.XMLHTTP");
			}
			catch(T) {}
		}
	}
	
	// полезные придумки
	this.hro = http_request;
	this.lastReq = {};
	this.lastRequest = function() { return this.lastReq }
	this.onload = function() {}
	this.onerror = function() { alert("Во время запроса ("+this.lastRequest().uri+") возникла проблема: "+this.status()+"."); }
	
	// бесполезные придумки
	this.tagTextValues = function(tname)
	{
		var elems = this.responseXML().getElementsByTagName(tname);
		var res = new Array();
		for(var i=0;i<elems.length;i++) res[i] = elems[i].firstChild.nodeValue;
		
		return res;
	}
	this.tagTextValue = function(tname)
	{
		return this.responseXML().getElementsByTagName(tname)[0].firstChild.nodeValue;
	}
	
	// методы XMLHttpRequest
	this.open = function(method,uri,async,user,password) { this.lastReq = {method:method,uri:uri,async:async,user:user,password:password}; return this.hro.open(method,uri,async,user,password) }
	this.setRequestHeader = function(header,value) { return this.hro.setRequestHeader(header,value) }
	this.send = function(data) { return this.hro.send(data) }
	this.abort = function() { return this.hro.abort() }
	this.getAllResponseHeaders = function() { return this.hro.getAllResponseHeaders() }
	this.getResponseHeader = function(header) { return this.hro.getResponseHeader(header) }
	
	// свойства XMLHttpRequest
	this.readyState = function() { return this.hro.readyState }
	this.responseText = function() { return this.hro.responseText }
	this.responseXML = function() { return this.hro.responseXML }
	this.status = function() { return this.hro.status }
	this.statusText = function() { return this.hro.statusText }
	
	
	this.onreadystatechange = function()
	{
		if(this.readyState() == 4)
		{
			if(this.status() == 200)
				this.onload();
			else
				this.onerror();
		}
	}
	
	if(http_request)
	{
		var to = this;
		http_request.onreadystatechange = function()
		{
			to.onreadystatechange();
		}
	}
	else alert('Сдаюсь :( Невозможно создать екземпляр XMLHTTP');
}



function asyncPost(url,params)
{
	var hr = new HttpRequest();
	
	if(!hr) return false;
	
	hr.open('POST', url, true);
	hr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
	hr.setRequestHeader("Content-length", params.length);
	hr.send(params);
	
	return hr;
}

function asyncGet(url)
{
	var hr = new HttpRequest();
	
	if(!hr) return false;
	
	hr.onload = function() { alert(this.responseText()); }
	
	hr.open('GET', url, true);
	hr.send(null);
	
	return hr;
}

function syncPost(url,params)
{
	var hr = new HttpRequest();
	
	if(!hr) return false;
	
	hr.open('POST', url, false);
	hr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
	hr.setRequestHeader("Content-length", params.length);
	hr.send(params);
	
	return hr.responseText();
}

function syncGet(url)
{
	var hr = new HttpRequest();
	
	if(!hr) return false;
	
	hr.open('GET', url, false);
	hr.send(null);
	
	return hr.responseText();
}


//————————————————————————————— Ручная обработка форм ——————————————————————————

function stringifyForm(fobj)
{
	var val, el;
	var arr = new Array();
	
	for(var i=0;i<fobj.elements.length;i++)
	{
		el = fobj.elements[i];
		
		if(el.type == "select-one") val = el.options[el.selectedIndex];
		if(el.type == "checkbox") val = el.checked?el.value:"";
		if(el.type == "radio") if(el.checked) val = el.value; else continue;
		else val = el.value;
		
		if(el.name) arr.push(encodeURI(el.name) + "=" + encodeURI(val));
	}
	
	return arr.join(";");
}



