
//-------------------
menu_root_dx = 0;
menu_root_dy = 0;
menu_dx = -9;
menu_dy = -6;
menu_dw = 20;
//-------------------


menus = new Array;
menus_comp = new Array;
menu_on = 0;

debug = 0;

var root_menu = "null";
menus["null"] = [];

function GMenu(mname){
    
    if(debug == 1) alert("GMenu(\""+mname+"\")");
    
    if(menus[mname] == undefined){ alert("Error! Menu with name '"+mname+"' does not exists!!!"); mname = "null"; }

    if(menus_comp[mname] == undefined)
	menus_comp[mname] = new Menu(mname);
    
    return menus_comp[mname];
}

function OnDown(e){

    var elem = e?e:event.srcElement;
    
    if(menu_on == 0 && GMenu(root_menu).v == 1){
	//GMenu(root_menu).sel;
	GMenu(root_menu).hide();
	root_menu = "null";
	return true;
    }
    
}

function OnCM(){
    
    elem = event.srcElement;
    objstr = "";
    
    while( !elem.getAttribute('objstr') && elem.tagName != "BODY" ){elem = elem.parentElement}
    
    objstr = elem.getAttribute('objstr');
    
    if(! objstr) return true;
    
    var x = event.x + id_body.scrollLeft - 2 + menu_root_dx;
    var y = event.y + id_body.scrollTop - 2 + menu_root_dy;
    var w = 100;
    
    //ar = objstr.split(":");
    
    
    root_menu = objstr;
    GMenu(root_menu).show(x,y,w);
    
    return false;
}

function Menu_show(x,y,w){
    
    if(this.v == 1) return;
    this.v = 1;
    
    
    //this.items_div.style.visibility  = "visible";
    this.items_div.style.posTop = y;
    this.items_div.style.posLeft = x;
    this.items_div.style.posWidth = w;
    this.items_div.style.zIndex = 20;
    
    document.body.appendChild(this.items_div);
    
    var tw = this.items_div.clientWidth + menu_dw;
    
    alldivs = this.items_div.all.tags("DIV");
    for(i=0;i<alldivs.length;i++) alldivs[i].style.posWidth = tw;
    
    this.sel.className = "cmenu_item";
}


function Menu_hide(x,y){
    
    if(this.v == 0) return;
    
    this.x = 0;
    this.y = 0;
    this.v = 0;
    
    this.sel.className = "cmenu_item";
    menu_on = 0;
    
    if(this.son != "") GMenu(this.son).hide();
    this.son = "null";
    document.body.removeChild(this.items_div);
    
    alldivs = this.items_div.all.tags("DIV");
    for(i=0;i<alldivs.length;i++) alldivs[i].style.posWidth -= menu_dw;
}

function Menu(mname){
    
    mas = new Array;
    mas = menus[mname];
    
    if(debug == 1) alert("Menu(\""+mname+"\")");
    
    this.x = 0;
    this.y = 0;
    this.w = 0;
    this.v = 0;
    this.items_div = document.createElement("DIV");
    this.items_div.className = "cmenu_bg";
    this.items_div.style.position = "absolute";
    this.son = "null";
    this.papa = "null";
    this.name = mname;
    this.hide_timer = "";
    this.show_timer = "";
    this.sel = document.createElement("DIV");
    
    onclick = "";
    
    for(i=0;i<mas.length;i++){
    
	if(mas[i][1].indexOf("menu:") == 0){
	    sname = mas[i][1].substring(5,mas[i][1].length);
	    this.items_div.innerHTML += "<div " +
	    " class=cmenu_item onmouseover=\"Menu_item_mouse_m(1,'"+mname+"','"+sname+"')\" onmouseout=\"Menu_item_mouse_m(0,'"+mname+"','"+sname+"')\" >" +
	    "<span class=cmenu_4><span style='position: relative; top: -4px'>4</span></span>" +
	    mas[i][0] + 
	    "</div>\n";
	}else if(mas[i][1].indexOf("hr:") == 0){
	    this.items_div.innerHTML += 
	    "<DIV class=cmenu_hr onmouseover='menu_on = 1' onmouseout='menu_on = 0'></DIV>";
	}else{
	    onclick = "";
	    if(mas[i][2]) onclick = " return "+mas[i][2]+";";
	    this.items_div.innerHTML += "<a target=\"admin_right\" onclick=\"OnDown(this); "+onclick+"\" href=\"" + mas[i][1] + "\"><DIV class=cmenu_item " +
	    " onmouseover=\"Menu_item_mouse(1,'"+mname+"');\" onmouseout=\"Menu_item_mouse(0,'"+mname+"')\" "+
	    ">" + mas[i][0] + "</DIV></a>\n";
	}		
    }
    
    this.show = Menu_show;
    this.hide = Menu_hide;
    
    return this;
}

function Menu_item_mouse(s,mname,sname){
    
    if(s == 1) event.srcElement.className = "cmenu_item_on";
    if(s == 0) event.srcElement.className = "cmenu_item";
    
    menu_on = s;
    
    if(s == 1){
	//GMenu(mname).sel = event.srcElement;
	GMenu(mname).sel.className = "cmenu_item";
	GMenu(GMenu(mname).papa).sel.className = "cmenu_item_on";
	GMenu(GMenu(mname).son).hide();
    }
}

function Menu_item_mouse_m(s,rmenu,smenu){
    
    var elem = event.srcElement;//.parentElement;
    
    while(elem.className != "cmenu_item" && elem.className != "cmenu_item_on")
	elem = elem.parentElement;
    
    if(s == 1){
	
	GMenu(rmenu).sel.className = "cmenu_item";
    }
    
    if(s == 1) elem.className = "cmenu_item_on";
    if(s == 0 && GMenu(rmenu).son == "null")
	elem.className = "cmenu_item";
    
    menu_on = s;
    
    if(s == 0) return;
    //if(smenu == GMenu(rmenu).son) return;
    
    
    elem.x = elem.getBoundingClientRect().right + id_body.scrollLeft + menu_dx;
    elem.y = elem.getBoundingClientRect().top + id_body.scrollTop + menu_dy;
    elem.w = elem.getBoundingClientRect().right - elem.getBoundingClientRect().left;
    
    if(debug == 1) alert("Menu_item_mouse_m(\""+smenu+"\")");
    
    if(GMenu(rmenu).son != "" && GMenu(rmenu).son != smenu) GMenu(GMenu(rmenu).son).hide();
    GMenu(rmenu).son = smenu;
    GMenu(rmenu).sel = elem;
    
    GMenu(smenu).papa = rmenu;
    GMenu(smenu).show(elem.x,elem.y,1); //elem.w
    GMenu(smenu).sel.className = "cmenu_item";
    
    return false;
}

function OnMove(){
    
    if(root_menu == "null") return true;
    
    elem = event.srcElement;
    relem = elem.parentElement;
    
    if(elem.language == "") return true;
    
    while(relem.className != "cmenu_root" && relem.tagName != "BODY") relem = relem.parentElement;
    
    if(relem.className == "cmenu_root"){
	
	if(elem.language == root_menu) return;
	OnDown(elem);
    }
    
    return false;
}

document.onmousedown = OnDown;
document.oncontextmenu = OnCM;
document.onmousemove = OnMove;
window.defaultStatus = "";





