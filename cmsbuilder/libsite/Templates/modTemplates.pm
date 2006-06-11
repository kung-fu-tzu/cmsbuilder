# (с) Леонов П.А., 2006

package modTemplates;
use strict qw(subs vars);
our @ISA = ('CMSBuilder::DBI::TreeModule');

our $VERSION = 1.0.0.0;

sub _cname {'Шаблоны'}
sub _add_classes {qw/TemplateDir/}
sub _aview {qw//}

sub _props
{
	'name'			=> { 'type' => 'string', 'length' => 25, 'name' => 'Название' },
}

#-------------------------------------------------------------------------------


sub install_code
{
	my $mod = shift;
	
	my $mr = modRoot->new(1);
	
	my $to = $mod->cre();
	$to->{'name'} = $mod->cname();
	$to->save();
	
	$mr->elem_paste($to);
	
	my $td = TemplateDir->cre();
	$td->{'name'} = 'Стандартные';
	$td->save();
	
	$to->elem_paste($td);
	
	my $tt = Template->cre();
	$tt->{'name'} = 'По умолчанию';
	$tt->{'content'} =
	'<html>
    <head>
        <title>${site_title}</title>
        <script language="javascript" type="text/javascript">//${site_script}</script>
    </head>
    <body>
        <meta content="${site_description}" name="description" />
        <table width="100%" border="1">
            <tbody>
                <tr>
                    <td width="20%">&nbsp;</td>
                    <td>${site_navigation}</td>
                </tr>
                <tr>
                    <td valign="top">${modSite.mainmenu}</td>
                    <td valign="top">
                    <h1>${site_textname}</h1>
                    ${site_contentbox}</td>
                </tr>
            </tbody>
        </table>
    </body>
</html>';
	$tt->save();
	
	$td->elem_paste($tt);
	
}

1;