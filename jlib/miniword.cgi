
sub asMiniWord
{

	print <<"ENDIT";

<script src="/editor/colors.js" language="JavaScript"></script>

<table width="100%" bgcolor="#F0F4F0">
<tr>
<td>
<table width="500" cellpadding="0" cellspacing="0" align="center" bgcolor="#F0F4F0">
<tr height="1" bgcolor="silver"><td colspan="26"></td></tr>

<tr height="28">
<td width="22" nowrap align="center">
<img src="editor/img/save.gif"  width="20" height="20" onClick="Save()" 
style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" alt="Сохранить">
</td><td width="22" nowrap align="center">
<img src="editor/img/print.gif"  width="20" height="20" onClick="PrintPage()" 
style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" alt="Печать">
</td><td>
<img src="editor/img/I.gif" width="5" height="20"border="0">
</td>
<td width="22" nowrap align="center">
<img src="editor/img/cut.gif"  width="20" height="20"   onClick="FormatText('cut')" 
style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" alt="Вырезать">
</td><td width="22" nowrap align="center">
<img src="editor/img/copy.gif"   width="20" height="20" onClick="FormatText('copy')" 
style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" alt="Копировать">
</td><td width="22" nowrap align="center">
<img src="editor/img/paste.gif"  width="20" height="20" onClick="FormatText('paste')" 
style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" alt="Вставить">
</td><td>
<img src="editor/img/I.gif" width="5" height="20"border="0">
</td><td width="22" nowrap align="center">
<img src="editor/img/preview.gif"  width="20" height="20"  onClick="Preview()" 
style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" alt="Просмотр страницы в браузере">
</td><td>
<img src="editor/img/I.gif" width="5" height="20"border="0">
</td><td width="22" nowrap align="center">
<img src="editor/img/undo.gif"  width="20" height="20"  onClick="FormatText('Undo', '')" 
style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" alt="Отменить">
</td><td width="22" nowrap align="center">
<img src="editor/img/redo.gif"  width="20" height="20"  onClick="FormatText('Redo', '')" 
style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" alt="Повторить">
</td>
<td>
<img src="editor/img/I.gif" width="5" height="20"border="0">
</td><td width="22" nowrap align="center">
<img src="editor/img/wlink.gif"  width="20" height="20"  onClick="Code = prompt('Введите URL для ссылки', 'http://'); 	if ((Code != null) && (Code != '')){ FormatText('CreateLink', Code); }"  
style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" alt="Вставить гиперссылку">
</td><td width="22" nowrap align="center">
<img src="editor/img/paragraf.gif"  width="20" height="20"  onClick="FormatText('InsertParagraph', 'false')" style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" alt="Новый абзац">
</td><td width="22" nowrap align="center">
<img src="editor/img/br.gif"  width="20" height="20"  onClick="AddHTML('<BR>')" style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" alt="Новая строка">
</td><td width="22" nowrap align="center">
<img src="editor/img/hr.gif"  width="20" height="20"  onClick="FormatText('InsertHorizontalRule', '')" 
style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" alt="Горизонтальная линия">
</td><td width="22" nowrap align="center">
<img src="editor/img/image.gif"  width="20" height="20"  onClick1="AddImage()" 
style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" alt="Вставить изображение">
</td>
<td width="22" nowrap align="center">
<img src="editor/img/margue.gif"  width="20" height="20"  onClick="FormatText('InsertMarquee', '')" 
style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" alt="Бегущая строка">
</td>
<td width="22" nowrap align="center">
<img src="editor/img/table.gif"  width="20" height="20"  onClick="InsertTable()" 
style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" alt="Вставить таблицу">
</td>
<td>
<img src="editor/img/I.gif" width="5" height="20"border="0">
</td>
<td width="28" nowrap align="center">
<img src="editor/img/div.gif" width="26" height="20" onClick="AddHTML('<DIV>DivSrc</DIV><P></P>')" 
style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" class="Im" alt="Тэг <div></div>">
</td>
<td width="33" nowrap align="center">
<img src="editor/img/span.gif" width="31" height="20" onClick="AddHTML('<SPAN>SpanText</SPAN>')" 
style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" class="Im" alt="Тэг <span></span>">
</td>
<td width="23" nowrap align="center">
<img src="editor/img/code.gif" width="21" height="20" onClick="Code = prompt('Введите HTML-код', ''); 	if ((Code != null) && (Code != '')){ AddHTML(Code); }" 
style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" class="Im" alt="Вставить произвольный HTML-код или текст">
</td>
<td>
<img src="editor/img/I.gif" width="5" height="20"border="0">
</td><td width="22" nowrap align="center">
<img src="editor/img/spravka.gif"  width="20" height="20"  onClick="alert('Справка\\\n\\\nОсновные вопросы и проблемы, возникающие при работе с редактором:\\\n - Редактор автоматически вырезает тэги &lt;script&gt;, тэги комментариев, тэги ASP и PHP,\\\n   равно как и другие тэги, не соответствующие спецификации HTML 4.0\\\n - При вставке ссылки-изображения возникает ошибка. Чтобы сделать изображение ссылкой введите\\\n   любой текст, сделайте его ссылкой, затем выделите полученный текст и вставьте на его место изображение\\\n - По другим вопросам свяжитесь в вебмастером.')" 
style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" alt="Справка">
</td>
<td width="400">
</td></tr>

<tr height="1" bgcolor="silver"><td colspan="30"></td></tr>
<tr><td nowrap colspan="30">
</td>
<table cellpadding="0" cellspacing="0" align="center"><tr height=28>
<td>

<select name="selectFont" onChange="FormatText('fontname', selectFont.options[selectFont.selectedIndex].value);document.Add.selectFont.options[0].selected = true;"  >
<option selected>-- Шрифт --</option>
<option value="Arial, Helvetica, sans-serif">Arial</option>
<option value="Courier New, Courier, mono">Courier New</option>
<option value="Times New Roman, Times, serif">Times New Roman</option>
<option value="Verdana, Arial, Helvetica, sans-serif">Verdana</option>
</select>

</td><td>

                <select name="selectSize" onChange="FormatText('fontsize', selectSize.options[selectSize.selectedIndex].value);document.Add.selectSize.options[0].selected = true;" >
                 <option selected>-- Размер --</option>
                 <option value="1">1</option>
                 <option value="2">2</option>
                 <option value="3">3</option>
                 <option value="4">4</option>
                 <option value="5">5</option>
                 <option value="6">6</option>
                </select>

</td>

<td width="22" nowrap align="center">
<img src="editor/img/bold.gif"  width="20" height="20"  onClick="FormatText('bold', '')" 
style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" alt="Жирный">
</td><td width="22" nowrap align="center">
<img src="editor/img/italic.gif"  width="20" height="20"  onClick="FormatText('italic', '')" 
style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" alt="Наклонный">
</td><td width="22" nowrap align="center">
<img src="editor/img/under.gif"  width="20" height="20"  onClick="FormatText('underline', '')" 
style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" alt="Подчеркнутый">
</td><td width="22" nowrap align="center">
<img src="editor/img/strike.gif" width="20" height="20"   onClick="FormatText('StrikeThrough', '')" 
style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" alt="Перечеркнутый">
</td><td>
<img src="editor/img/I.gif" width="5" height="20"border="0">
</td><td width="22" nowrap align="center">
<img src="editor/img/fcolor.gif"  width="20" height="20"  onClick="OpenColors('/')" 
style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" alt="Выбор цвета">
</td><td>
<img src="editor/img/I.gif" width="5" height="20"border="0">
</td><td width="22" nowrap align="center">
<img src="editor/img/aleft.gif"  width="20" height="20"  onClick="FormatText('JustifyLeft', '')" 
style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" alt="Выровнять по левому краю">
</td><td width="22" nowrap align="center">
<img src="editor/img/center.gif"  width="20" height="20"  onClick="FormatText('JustifyCenter', '')" 
style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" alt="Выровнять по центру">
</td><td width="22" nowrap align="center">
<img src="editor/img/aright.gif"  width="20" height="20"  onClick="FormatText('JustifyRight', '')" 
style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" alt="Выровнять по правому краю">
</td><td>
<img src="editor/img/I.gif" width="5" height="20"border="0">
</td>
<td width="22" nowrap align="center">
<img src="editor/img/blist.gif" onMouseOver="b(this)" onMouseOut="a(this)"   width="20" height="20" onClick="FormatText('InsertUnorderedList', '')" 
style="cursor: hand;" alt="Простой список">
</td><td width="22" nowrap align="center">
<img src="editor/img/nlist.gif"   width="20" height="20" onClick="FormatText('InsertOrderedList', '')" 
style="cursor: hand;" onMouseOver="b(this)" onMouseOut="a(this)" alt="Нумерованный список">
</td>
</tr>

<tr height="1" bgcolor="silver"><td colspan="30"></td></tr>
</table>

<table align="center"><tr><td>
<script language="JavaScript">
function sh() { frames.message.document.body.innerHTML = Add.r_text.value; }
</script>
<div id="Frm"><iframe src="editor/src.html" id="message" width="500" height="300" onLoad="sh()"></iframe></div><textarea name="r_text" style="width:500px;height=298px;display:none"></textarea>
<script language="JavaScript">
HTMLmode = 0;
frames.message.document.designMode = "On";
</script>
<div id="im1">
<img name="Normal" src="editor/img/Normal.gif" width="108" height="17" border="0" usemap="#m_Normal">
<map name="m_Normal">
<area shape="poly" coords="59,1,56,8,59,15,99,15,105,3,104,1,59,1" href="javascript:ShowHTML();">
</map>
</div>
<div id="im2" style="display:none">
<img name="HTML" src="editor/img/HTML.gif" width="108" height="17" border="0" usemap="#m_HTML">
<map name="m_HTML">
<area shape="poly" coords="1,1,51,0,55,9,53,15,8,15,2,3,1,1" href="javascript:ShowNormal();">
</map>
</div>
</td></tr>
</table>
<td></tr>
</table>

<script src="/editor/editor.js" language="JavaScript"></script>
<script src="/editor/link.js" language="JavaScript"></script>
<script src="/editor/table.js" language="JavaScript"></script>

ENDIT

}

1;