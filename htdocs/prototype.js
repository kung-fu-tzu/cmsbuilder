
function classA ()
{
	this.name = "A"
}

classA.prototype.show = function ()
{
	alert("classA.show: " + this.name)
}

classA.prototype.hide = function ()
{
	alert("classA.hide: " + this.name)
}


classB.prototype = new classA()

function classB ()
{
	classA.call(this)
	this.name += "B"
}

classB.prototype.show = function ()
{
	classA.prototype.show.call(this)
	alert("classB.show: " + this.name)
}

var o = new classB();

o.show()
o.hide()