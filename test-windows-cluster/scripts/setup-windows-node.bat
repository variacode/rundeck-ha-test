@echo off

echo Disabling firewall
netsh advfirewall set allprofiles state off

echo Installing java JRE...
c:\files\jre-8u91-windows-x64.exe /s

echo Installing tomcat...
c:\files\apache-tomcat-7.0.70.exe /S /D=c:\tomcat7

echo Copy tomcat config
robocopy c:\config\tomcat7\conf c:\tomcat7\conf /E /NFL /NDL /NJH /nc /ns /np

echo Create rundeck fil structure...
robocopy c:\rundeck_config c:\rundeckpro /E /NFL /NDL /NJH /nc /ns /np

echo Deploy rundeck...
copy c:\rundeckpro.war c:\tomcat7\webapps

echo Starting tomcat
c:\tomcat7\bin\tomcat7.exe start

echo Sleeping 1 minute to get rundeck deployed...
timeout 60 /NOBREAK

echo Copy additionatl log4j file...
robocopy c:\config\tomcat7\webapps c:\tomcat7\webapps /E /NFL /NDL /NJH /nc /ns /np

echo Deploy rundeck-system plugin
copy c:\files\rundeck-system-windows.zip c:\rundeckpro\libext

echo restart tomcat...
c:\tomcat7\bin\tomcat7.exe stop
timeout 6 /nobreak
echo killing tomcat...
taskkill /F /T /IM Tomcat7.exe
timeout 2 /nobreak
c:\tomcat7\bin\tomcat7.exe start

echo Sleeping one minute to get rundeck started...
timeout 60 /NOBREAK

echo Done.
