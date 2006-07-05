@ECHO OFF

rmdir /s /q \@work\cmsbuilder2

xcopy /e /q .\cgi-bin\*.* \@work\cmsbuilder2\cgi-bin\*.*
xcopy /e /q .\cmsbuilder\*.* \@work\cmsbuilder2\cmsbuilder\*.*
xcopy /e /q .\htdocs\*.* \@work\cmsbuilder2\htdocs\*.*
pause