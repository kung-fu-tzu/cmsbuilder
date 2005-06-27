

//------------------------------ Базовые переменные -----------------------------

var all_menus = new Object();
var all_menus_code = new Object();
var last_onclick;
var now_menu;
var body = document.body;
var doc = document;


//------------------------------ Вспомогательные функции ------------------------

function OnContext(o)
{
	if(o == undefined) return true;
	
	var name = o.id;
	name = name.replace('cmenu_','');
	
	if(all_menus_code[name] != undefined)
	{
		eval(all_menus_code[name]);
		all_menus_code[name] = undefined;
	}
	if(all_menus[name] == undefined) return true;
	
	if(now_menu) OnClickAfterContext();
	
	last_onclick = document.body.onclick;
	document.body.onclick = OnClickAfterContext;
	now_menu = all_menus[name];
	
	
	var x = event.x + body.scrollLeft;
	var y = event.y + body.scrollTop;
	
	
	now_menu.show(x,y);
	
	return false;
}

function OnClickAfterContext()
{
	if(now_menu == undefined) return true;
	
	document.body.onclick = last_onclick;
	now_menu.hide();
	now_menu = undefined;
	
	return false;
}

document.onkeypress = function()
{
	if(event.keyCode != 27) return true;
	
	OnClickAfterContext();
}


//------------------------------ Собственно менюхи -------------------------------


// Базовый класс замороченных боксов
function JBox(tag)
{
	var nobj;
	nobj = document.createElement(tag || "DIV");
	nobj.className = 'cmenu_menu';
	nobj.visible = 0;
	nobj.ismouseon = 0;
	nobj.papa = document.body;
	nobj.son = undefined;
	nobj.temp_x = 0;
	nobj.temp_y = 0;
	
	nobj.show = function(nx,ny)
	{
		if(this.visible) return;
		this.moveto(nx || 0, ny || 0);
		this.visible = 1;
		this.papa.appendChild(this);
	}
	
	nobj.hide = function()
	{
		if(!this.visible) return;
		if(this.son){ this.son.hide(); }
		
		this.visible = 0;
		this.papa.removeChild(this);
	}
	
	nobj.togle = function()
	{
		if(this.visible) this.hide();
		else this.show();
	}
	
	nobj.moveto = function(nx,ny)
	{
		this.style.posLeft = nx || this.temp_x;
		this.style.posTop = ny || this.temp_y;
		
		this.temp_x = this.style.posLeft;
		this.temp_y = this.style.posTop
	}
	
	nobj.onmouseover = function(){ this.ismouseon = 1; }
	
	nobj.onmouseout = function(){ this.ismouseon = 0; }
	
	nobj.elem_add = function(elem)
	{
		if(elem.papa != this)
		{
			elem.papa.elem_del(elem);
			elem.papa = this;
		}
		
		elem.show();
		
		return elem;
	}
	
	nobj.elem_del = function(elem)
	{
		if(elem.papa != this) return;
		
		elem.hide();
		elem.papa = document.body;
	}
	
	nobj.oncontextmenu = function()
	{
		return false;
	}
	
	return nobj;
}

// Класс меню. Основан на: JBox.
function JMenu()
{
	var nobj;
	nobj = JBox("TABLE");
	
	var ntd = document.createElement('td');
	var ntr = document.createElement('tr');
	var ntbody = document.createElement('tbody');
	
	ntr.appendChild(ntd);
	ntbody.appendChild(ntr);
	nobj.appendChild(ntbody);
	
	nobj.td = ntd;
	
	nobj.cellPadding = 0;
	nobj.cellSpacing = 0;
	
	nobj.old_onmouseover = nobj.onmouseover;
	nobj.old_hide  = nobj.hide;
	
	nobj.onmouseover = function()
	{
		if(this.my_JMISubMenu)
			this.my_JMISubMenu.select();
		
		return this.old_onmouseover();
	}
	
	nobj.hide = function()
	{
		if(this.my_JMISubMenu)
			this.my_JMISubMenu.deselect();
		
		return this.old_hide();
	}
	
	nobj.appendChild = function(chld)
	{
		return nobj.td.appendChild(chld);
	}
	
	nobj.onclick = function()
	{
		window.event.cancelBubble = true;
		if(this.sel)
			this.sel.onmouseout();
		
		//this.hide();
		if(now_menu) now_menu.hide();
	}
	
	return nobj;
}

// Класс элемента меню. Основан на JBox.
function JMenuItem(itext)
{
	var nobj;
	nobj = JBox("DIV");
	
	nobj.moveto = function(nx,ny){}
	nobj.className = "cmenu_item_out";
	nobj.innerHTML = itext;
	
	nobj.onmouseover = function()
	{
		if(this.papa.son) this.papa.son.hide();
			this.ismouseon = 1;
		
		this.select();
	}
	
	nobj.onmouseout = function()
	{
		this.ismouseon = 0;
		this.deselect();
	}
	
	nobj.deselect = function()
	{
		if(this.papa)
			this.papa.sel = undefined;
		
		this.className = "cmenu_item_out";
	}
	
	nobj.select = function()
	{
		if(this.papa)
			this.papa.sel = this;
		
		this.className = "cmenu_item_on";
	}
	
	nobj.onmousedown = function()
	{
		this.className = "cmenu_item_down";
		//this.onmouseout();
	}
	
	return nobj;
}


function JMISubMenu(itext,smenu)
{
	var nobj;
	nobj = JMenuItem('<table width="100%" class="cmenu_JMISubMenu" cellPadding="0" cellSpacing="0"><tr><td>'+itext+'</td><td>&nbsp;</td><td><div class="cmenu_4">&#9658;</div></td></tr></table>');
	
	nobj.smenu = smenu;
	
	nobj.old_onmouseover = nobj.onmouseover;
	nobj.old_onmouseout  = nobj.onmouseout;
	
	nobj.onmouseover = function()
	{
		var ret = nobj.old_onmouseover();
		this.papa.son = smenu;
		
		smenu.my_JMISubMenu = this;
		smenu.show(0,0);
		
		var x = this.getBoundingClientRect().left + body.scrollLeft;
		var y = this.getBoundingClientRect().top - (this.smenu.getBoundingClientRect().bottom - this.smenu.getBoundingClientRect().top)/2 + body.scrollTop;
		var w = this.getBoundingClientRect().right - this.getBoundingClientRect().left;
		
		smenu.moveto(x+w,y);
		
		return ret;
	}
	
	nobj.onclick = function()
	{
		window.event.cancelBubble = true;
	}
	
	nobj.onmousedown = function(){}
	
	return nobj;
}

function JMIHref(itext,ihref,targ)
{
	var nobj;
	nobj = JMenuItem(itext);
	nobj.href = ihref;
	nobj.target = targ;
	
	nobj.onclick = function()
	{
		if(this.target)
		{
			this.target.location.href = this.href;
		}
		else
		{
			if(CMS_HaveParent()) parent.frames.admin_right.location.href = this.href;
			else document.location.href = this.href;
		}
	}
	
	return nobj;
}

function JMIDelete(itext,ihref,targ)
{
	var nobj;
	nobj = JMenuItem(itext);
	nobj.href = ihref;
	nobj.target = targ;
	
	nobj.onclick = function()
	{
		var dodel = doDel();
		OnClickAfterContext();
		if(!dodel) return;
		
		if(this.target)
		{
			this.target.location.href = this.href;
		}
		else
		{
			parent.frames.admin_right.location.href = this.href;
		}
	}
	
	return nobj;
}

function JHR()
{
	var nobj;
	nobj = JBox('DIV');
	nobj.className = 'cmenu_hr';
	
	nobj.onclick = function()
	{
		window.event.cancelBubble = true;
		return false;
	}
	
	return nobj;
}

function JTitle(str)
{
	var nobj;
	nobj = JBox('DIV');
	nobj.className = 'cmenu_title';
	nobj.innerHTML = str;
	
	nobj.onclick = function()
	{
		window.event.cancelBubble = true;
		return false;
	}
	
	return nobj;
}

body.elem_del = function(elem){ elem.hide(); }


