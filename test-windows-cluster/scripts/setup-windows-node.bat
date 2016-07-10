@echo off

echo Disabling firewall
netsh advfirewall set allprofiles state off

echo Installing 7z
c:\files\7z1602-x64.exe /S /D=c:\7z
set PATH=%PATH%;C:\7z

echo Installing java JRE...
c:\files\jre-8u91-windows-x64.exe /s

echo Installing tomcat...
c:\files\apache-tomcat-7.0.70.exe /S /D=c:\tomcat7

echo Copying tomcat config
robocopy c:\config\tomcat7\conf c:\tomcat7\conf /E /NFL /NDL /NJH /nc /ns /np

echo Creating rundeck file structure...
robocopy c:\rundeck_config c:\rundeckpro /E /NFL /NDL /NJH /nc /ns /np

echo Deploying rundeck...
copy c:\rundeckpro.war c:\tomcat7\webapps
7z x c:\rundeckpro.war -oc:\tomcat7\webapps\rundeckpro -r
robocopy c:\config\tomcat7\webapps c:\tomcat7\webapps /E /NFL /NDL /NJH /nc /ns /np

echo Deploy rundeck-system plugin
copy c:\files\rundeck-system-windows.zip c:\rundeckpro\libext

echo Start Tomcat...
c:\tomcat7\bin\tomcat7.exe start

echo Sleeping one minute to get rundeck started...
timeout 60 /NOBREAK

echo Done.
