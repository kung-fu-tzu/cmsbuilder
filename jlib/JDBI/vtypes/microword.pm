# (с) Леонов П.А., 2005

package JDBI::vtypes::microword;
our @ISA = 'JDBI::VType';
# Микроворд #####################################################

sub table_cre
{
	return ' TEXT ';
}

sub aview
{
	my $class = shift;
	my $name = shift;
	my $val = shift;

	$val =~ s/\&/\&amp;/g;
	$val =~ s/\"/\&quot;/g;
	$val =~ s/\</\&lt;/g;
	$val =~ s/\>/\&gt;/g;
	
	my $ret = <<MICRO;
	
	<TEXTAREA class=admin_input name="${name}" style="DISPLAY: none; HEIGHT: 148px;  WIDTH: 300px">$val</TEXTAREA>
	<script>${name}_mw_loaded = 0;</script>
	<iframe frameborder=1 class=admin_input src="/admin/microword.html" id="${name}_mw" style="HEIGHT: 150px; WIDTH: 300px"
	
		onload="${name}_mw.document.body.innerHTML = ${name}.value; ${name}_mw.document.designMode = 'On'; ${name}_mw_loaded = 1;"
		onmouseout = "if(!${name}_mw_loaded) return; ${name}.value = ${name}_mw.document.body.innerHTML"
		onmouseover = "if(!${name}_mw_loaded) return; ${name}.value = ${name}_mw.document.body.innerHTML"
		onkeyup = "if(!${name}_mw_loaded) return; ${name}.value = ${name}_mw.document.body.innerHTML"
		
	></iframe><br>
	<INPUT type="button" value="HTML"   onclick=' ${name}.style.display = "block"; document.all.${name}_mw.style.display = "none";  ${name}_to_norm.style.display = "block"; ${name}_to_html.style.display = "none";'  id="${name}_to_html">
	<INPUT type="button" value="Normal" onclick=' ${name}.style.display = "none";  document.all.${name}_mw.style.display = "block"; ${name}_to_norm.style.display = "none";  ${name}_to_html.style.display = "block"; ${name}_mw.document.body.innerHTML = ${name}.value;' id="${name}_to_norm" style="DISPLAY: none">

MICRO
	
	return $ret;
}

1;