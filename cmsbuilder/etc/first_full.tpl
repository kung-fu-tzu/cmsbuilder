<html>
    <head>
        <title>${site_title}</title>
        <script language="javascript" type="text/javascript" src="/ajax.js"></script>
        <script language="javascript" type="text/javascript" src="/modForms.js"></script>
        <script language="javascript" type="text/javascript" src="/modShop.js"></script>
        <link rel="stylesheet" type="text/css" href="/modForms.css"/>
        <link rel="stylesheet" type="text/css" href="/modSite.css"/>
        <link rel="stylesheet" type="text/css" href="/modShop.css"/>
        <link rel="stylesheet" type="text/css" href="/modCatalog.css"/>
        <meta name="description" content="${site_description}"/>
    </head>
    <body>
        <table width="100%" border="1">
            <tbody>
                <tr>
                    <td width="20%">${modRegistration::modRegistration1->userform}</td>
                    <td>${site_navigation}</td>
                </tr>
                <tr>
                    <td valign="top">${modSite::modSite1->site_flatlist}</td>
                    <td valign="top">
                    <h1>${site_head}</h1>
                    ${site_content} ${site_pagesline}</td>
                </tr>
            </tbody>
        </table>
    </body>
</html>