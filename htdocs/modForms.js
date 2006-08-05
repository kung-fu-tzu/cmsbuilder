

function modForms_check(fobj,href)
{
	if(fobj.checked) return true;
	
	var data = stringifyForm(fobj) + ";form-sub-act=check";
	
	var r = asyncPost(href,data);
	r.form = fobj;
	r.onload = function()
	{
		//alert(this.responseText());
		modForms_unlock(this.form);
		
		var errs = this.tagTextValues("error");
		var oks = this.tagTextValues("ok");
		
		//alert(oks);
		
		modForms_mark(this.form,errs,"error");
		modForms_mark(this.form,oks,"ok");
		
		if(!errs.length)
		{
			this.form.checked = true;
			this.form.submit();
		}
	}
	
	modForms_lock(fobj);
	
	return false;
}

function modForms_mark(fobj,flds,cname)
{
	for(var i=0;i<flds.length;i++)
	{
		el = fobj[flds[i]];
		if(el) el.className = cname;
	}
}

function modForms_lock(fobj)
{
	for(var i=0;i<fobj.elements.length;i++)
	{
		el = fobj.elements[i];
		el.disabled = "disabled";
	}
}

function modForms_unlock(fobj)
{
	for(var i=0;i<fobj.elements.length;i++)
	{
		el = fobj.elements[i];
		el.disabled = "";
	}
}