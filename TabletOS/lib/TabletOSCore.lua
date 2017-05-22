local a={}local b=require("filesystem")local c=require("computer")local d=require("component")local e=require("ECSAPI")local f=require("term")local g=d.gpu;a.languagePackages={en={settings="Settings",shutdown="Shutdown",reboot="Reboot",language="Language",selLanguage="Select language",monitorOnline="Monitor",enterNickname="Enter nickname:",newFolder="New folder",newFile="New file",updateFileList="Update files",fileManager="File Manager",power="Sleep",update="Update avaliable!",appsLauncher="All apps",appInstall="Install",appUninstall="Uninstall",appInstalled="Installed"},ru={settings="Настройки",shutdown="Выключить",reboot="Перезагрузить",language="Язык",selLanguage="Выберите язык",monitorOnline="Монитор",enterNickname="Введите никнейм игрока:",newFolder="Новая папка",newFile="Новый файл",updateFileList="Обновить",fileManager="Файлы",power="Сон",update="Доступно обновление!",appsLauncher="Все программы",appInstall="Установить",appUninstall="Удалить",appInstalled="Установлено"}}a.language="en"function a.getLanguage()local h,i=io.open("/.tabletos","r")if h then a.language=h:read(b.size("/.tabletos")+1)h:close()return a.language else local h=io.open("/.tabletos","w")h:write("en")h:close()return"en"end end;function a.saveLanguage()b.remove("/.tabletos")local h=io.open("/.tabletos","w")h:write(a.language)h:close()end;function a.changeLanguage(j)if j then c.pushSignal("changeLanguage",a.language,j)a.language=j;a.saveLanguage()end end;function a.getLanguagePackages()return a.languagePackages[a.getLanguage()]end;function a.internetRequest(k)local l,m=pcall(d.internet.request,k)if l then local n=""while true do local o,p=m.read()if o then n=n..o else if p then return false,p else return true,n end end end else return false,m end end;function a.getFile(k,q)local l,r=a.internetRequest(k)if l then b.makeDirectory(b.path(q)or"")b.remove(q)local s=io.open(q,"w")if s then s:write(r)s:close()end;return true,r else return false,r end end;function a.downloadFileListAndDownloadFiles(t,u)if u then print("Downloading file list")end;local l,v=a.internetRequest(t)if l then local w=load("return "..v)local l,x=pcall(w)if l then for y=1,#x do a.getFile(x[y].url,x[y].path)if u then print("Downloading "..x[y].path)end end else error(x)end else error(v)end end;function a.saveDisplayAndCallFunction(...)local z,A=d.gpu.getResolution()local B=e.rememberOldPixels(1,1,z,A)local C={pcall(...)}e.drawOldPixels(B)return table.unpack(C)end;return a
