

//document.body.ondragend = function () { window.setTimeout("SafeRefresh()",1500,"JavaScript"); }

//window.ondragdrop = function(e){ alert(e); }

//——————————————————————————————————————————————————————————————————————————————

var flt_mm;
var flt_mu;
var flt_ss;
var flt_mx;
var flt_tw;

function CMS_Float_MD(obj)
{
	flt_mx = event.x;
	flt_tw = id_left_td.width * 1;
	
	movemodalwindow.style.display = "block";
	
	flt_mm = document.onmousemove;
	flt_mu = document.onmouseup;
	flt_ss = document.onselectstart;
	
	document.onmousemove = CMS_Float_MM;
	document.onmouseup = CMS_Float_MU;
	document.onselectstart = function () { return false; }
	
	return false;
}

function CMS_Float_MU(obj)
{
	document.onmousemove = flt_mm;
	document.onmouseup = flt_mu;
	
	movemodalwindow.style.display = "none";
	
	document.cookie = "left_td = width&" + id_left_td.width;
	
	return false;
}

function CMS_Float_MM()
{
	id_left_td.width = flt_tw + event.x - flt_mx;
	
	return false;
}

var nowicon;
var panel_options = new Object();

function selectLeftPanel(iobj_id)
{
	//if(!plid) return false;
	
	var iobj = document.getElementById(iobj_id);
	var pobj = document.getElementById("admin_left");
	if(!(iobj && pobj)) return false;
	
	if(nowicon == iobj) return false;
	
	pobj.src = iobj.href;
	
	if(nowicon) nowicon.className = "";
	iobj.className = "selected";
	
	nowicon = iobj;
	
	return false;
}

function HideLeft()
{
	id_left_td.style.display = "none";
	id_left_border.style.display = "none";
	
	btn_treeshow.style.display = "block";
	btn_treehide.style.display = "none";
	btn_treeresize.style.display = "none";
	
	return false;
}

function ShowLeft()
{
	id_left_td.style.display = "block";
	id_left_border.style.display = "block";
	
	btn_treeshow.style.display = "none";
	btn_treehide.style.display = "block";
	btn_treeresize.style.display = "block";
	
	return false;
}

//——————————————————————————————————————————————————————————————————————————————

window.onunload = function ()
{
	//if(document.all["main_form"])
	//{
	//	if(confirm("Сохранить зменения?")) document.all["main_form"].submit();
	//}
}

function QuickSubmit(obj)
{
	if(event.keyCode == 13 && event.ctrlKey)
	{
		obj.submit();
		return false;
	}
}

function SetOnChange(obj)
{
	var i,alla;
	//if(obj.all == undefined) return;
	
	obj.onchange = function () { this.parentElement.onchange(); };
	
	alla = obj.all;
	for(i=0;i<alla.length;i++)
	{
		//document.write("<img src=\"img/null.gif\" height=\"1\" width=\"",u*10,"\">[",alla[i].tagName,"]<br>");
		SetOnChange(alla[i]);
	}
}

function CMS_FMTogleE(){
	
	if(files_list.contentEditable == 'inherit')
		files_list.contentEditable = 'true', files_list.className = 'fileman_fs_div';
	else
		files_list.contentEditable = 'inherit', files_list.className = '';
}

function ShowHide(obj,dot)
{
	if(obj.style.display == "none")
	{
		obj.style.display = "block";
		dot.src = "img/minus.gif";
		document.cookie = obj.id + '=s&1;';
	}
	else
	{
		obj.style.display = "none";
		dot.src = "img/plus.gif";
		document.cookie = obj.id + '=s&0;';
	}
}

function ShowHideFieldsets()
{
	var arr = document.getElementsByTagName('fieldset');
	
	for(var i=0;i<arr.length;i++)
	{
		arr[i].style.display = getCookie(arr[i].id).s?"block":"none";
	}
}

function getCookie(name)
{
	if(document.cookie.length <= 0) return null;
	
	begin = document.cookie.indexOf(name+"=");
	if(begin == -1) return null;
	
	begin += name.length+1;
	end = document.cookie.indexOf(";", begin);
	if(end == -1) end = document.cookie.length;
	
	var arr = document.cookie.substring(begin, end).split("&");
	var co = new Object;
	for(var i=0;i<arr.length;i+=2) co[arr[i]] = unescape(arr[i+1]);
	
	return co;
}


function doDel()
{
	return window.confirm('Удалить?');
}

var SelectMod_old;
function SelectMod(obj,lh,rh)
{
	if(obj)
	{
		if(SelectMod_old) SelectMod_old.className = 'objtbl';
		obj.className = 'selected_item';
		SelectMod_old = obj;
	}
	
	parent.document.getElementById("admin_modules_icon").href = lh;
	parent.selectLeftPanel("admin_modules_icon");
	
	parent.admin_left.location.href = lh;
	parent.admin_right.location.href = rh;
}

var prev_obj;

function CMS_SelectLO(obj)
{
	if(window.name != 'admin_left') return false;
	if(!document.all[obj]) return false;
	
	if(document.all[prev_obj]) document.all[prev_obj].className = 'objtbl';
	
	document.all[obj].className = 'selected_item';
	
	prev_obj = obj;
	
	return true;
}

document.CMS_SelectLO = CMS_SelectLO;

function CMS_ShowMe(url)
{
	if(document.all['dbi_'+url])
	{
		document.all['dbi_'+url].style.display = "block";
		document.cookie = document.all['dbi_'+url].id + " = s&1";
	}
	
	if(document.all['treenode_'+url])
	{
		document.all['treenode_'+url].src = "img/minus.gif";
	}
}

function CMS_ModSelected(lurl,rurl)
{
	
}

function CMS_HaveParent()
{
	return parent.document != document;
}

function CMS_GetTypedElement(elem,type)
{
	do
	{
		if(elem.otype == type) return elem;
	}
	while((elem = elem.parentElement) && (elem != document.body));
	
	return undefined;
}

//——————————————————————————————————————————————————————————————————————————————

function CMS_GlobalDragStart(obj)
{
	if(!obj.myurl) return true;
	event.dataTransfer.setData("text",stringify(obj));
	
	event.dataTransfer.effectAllowed = "all";
	event.dataTransfer.dropEffect = "move";
}

function CMS_GlobalDragOver(obj)
{
	var dro = destringify(event.dataTransfer.getData("text"));
	event.cancelBubble = true;
	
	if(!dro.myurl || dro.myurl == obj.myurl) return true;
	if(!dro.papa && !event.shiftKey) return true;
	
	var durl = CMS_url2classid(dro.myurl);
	var murl = CMS_url2classid(obj.myurl);
	
	if(!durl.cn || !durl.id) return true;
	if(!CMS_array_can_add(murl.cn,durl.cn)) return true;
	
	
	if(obj.cms_ondragover_f)
		obj.cms_ondragover_f()
	else
		if(obj.cms_ondragover)
		{
			var func = eval("cms_ondragover = function () { "+obj.cms_ondragover+"}");
			obj.cms_ondragover_f = func;
			obj.cms_ondragover_f();
			//alert(obj.cms_ondragover)
		}
	
	if(!dro.papa) event.dataTransfer.dropEffect = "link";
	else if(event.ctrlKey) event.dataTransfer.dropEffect = "copy";
	else if(event.shiftKey) event.dataTransfer.dropEffect = "link";
	else event.dataTransfer.dropEffect = "move";
	
	event.returnValue = false;
}

function CMS_GlobalDrop(obj)
{
	var dro = destringify(event.dataTransfer.getData("text"));
	event.cancelBubble = true;
	
	obj.ondragleave();
	
	var sact = "move";
	if(event.ctrlKey) sact = "copy";
	if(event.shiftKey) sact = "shcut";
	if(!dro.papa) sact = "shcut"; //Если указано - делать только ссылку, то только ссылку и делаем :)
	
	var href = "right.ehtml?url="+obj.myurl+"&act=cms_array_object_move&sact="+sact+"&ourl="+dro.myurl+"&pos="+(obj.elempos||"");
	
	parent.admin_temp.location.href = href;
}

function CMS_array_can_add(mcn,cn)
{
	return (indexA(g_add_classes[mcn],cn) >= 0);
}

function CMS_url2classid(url)
{
	var urla = url.replace(/^([A-Za-z\.]+)(\d+)$/,"$1-$2").split(/\-/);
	
	var res = new Object;
	res.cn = urla[0];
	res.id = urla[1];
	
	return res;
}

function tellXY(oname)
{
	//alert("tellXY" + oname);
	
	if(!document[oname]) return {x:0,y:0};
	alert(oname);
	//return {x: document[oname].style.clientLeft, y: document[oname].style.clientTop};
}

function indexA(arr,val)
{
	if(!arr) return -1;
	
	for(var i=0;i<arr.length;i++)
		if(arr[i] == val) return i;
		
	return -1;
}

function SafeRefresh()
{
	//document.location.reload();
	document.location.href = document.location.href;
}

function stringify(obj)
{
	var val;
	var str = '[';
	
	for(var name in obj)
	{
		val = new String(obj[name]);
		/*val.replace(/\\/g,'\\\\');
		val.replace(/\n/g,'\\n');
		val.replace(/"/g,'\\"');*/
		
		if(val.indexOf("\n") == -1 && val.indexOf("\\") == -1 && val.indexOf("\"") == -1)		
			str += '"'+name+'","'+val+'",';
	}
	
	str += '"stringifyed",true]';
	
	return str;
}

function destringify(str)
{
	var obj = new Object;
	var arr;
	
	try { arr = eval(str); } catch(ex) { arr = ['eroor',ex]; }
	
	if(arr)
	{
		for(var i=0;i<arr.length;i+=2)
		{
			obj[arr[i]] = arr[i+1];
		}
	}
	
	return obj;
}

//var rps = new Object();

function rpcall(href)
{
	if(!href) return;
	var a = document.createElement('script');
	document.body.appendChild(a);
	a.src = href;
	
	/*var num = Math.random();
	rps[num] = arguments;
	a.src = href+"&rpnum="+num;*/
}

//function rpreq(num)
//{
//	if(!href) return;
//	var a = document.createElement('script');
//	document.body.appendChild(a);
//	a.src = href;
//}


