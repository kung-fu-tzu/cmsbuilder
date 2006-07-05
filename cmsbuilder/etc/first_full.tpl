<html>
    <head>
        <title>${site_title}</title>
        <script language="javascript" type="text/javascript" src="/ajax.js"></script>
        <script language="javascript" type="text/javascript" src="/plgnForms.js"></script>
        <script language="javascript" type="text/javascript" src="/plgnShop.js"></script>
        <link rel="stylesheet" type="text/css" href="/plgnForms.css"/>
        <link rel="stylesheet" type="text/css" href="/plgnSite.css"/>
        <link rel="stylesheet" type="text/css" href="/plgnShop.css"/>
        <link rel="stylesheet" type="text/css" href="/plgnCatalog.css"/>
        <meta name="description" content="${site_description}"/>
    </head>
    <body>
        <table width="100%" border="1">
            <tbody>
                <tr>
                    <td width="20%">${modRegistration1->userform}</td>
                    <td>${site_navigation}</td>
                </tr>
                <tr>
                    <td valign="top">${modSite1->site_flatlist}</td>
                    <td valign="top">
                    <h1>${site_head}</h1>
                    ${site_content} ${site_pagesline}</td>
                </tr>
            </tbody>
        </table>
    </body>
</html>