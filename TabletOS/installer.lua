local a=require("component")local b=require("computer")local c=require("filesystem")local d=require("shell")local e=require("event")local f=io.write;local g=io.read;local h=a.gpu;local i,j=h.maxResolution()if i>80 or i<80 then print("TabletOS requires resolution 80,25.")return end;h.setResolution(i,j)local k=0;local function l(m)local n,o=pcall(a.internet.request,m)if n then local p=""while true do local q,r=o.read()if q then p=p..q else if r then return false,r else return true,p end end end else return false,reason end end;local function s(m,t)local n,reason=l(m)if n then c.makeDirectory(c.path(t)or"")c.remove(t)local u=io.open(t,"w")if u then u:write(reason)u:close()end;return reason else print("")error(reason)end end;io.write("Downloading file list    ")local v=b.uptime()local w,x=l("https://raw.githubusercontent.com/HeroBrine1st/OpenComputers/master/TabletOS/applications.txt")if not w then error(x)end;local n,y=pcall(load("return"..x))if not n then io.stderr:write("Failed. Total time: "..tostring(b.uptime()-v).." Reason: "..reason.."\n")return end;io.write("Success. Total time: "..tostring(b.uptime()-v).."s\n")local function z()local A,B,C={},{},{}local D=y;for E=1,#D do if x.gsub(c.path(D[E].path),"/","")=="apps"then table.insert(A,D[E])elseif x.gsub(c.path(D[E].path),"/","")=="lib"then table.insert(B,D[E])else table.insert(C,D[E])end end;y={}for E=1,#C do table.insert(y,C[E])end;for E=1,#A do table.insert(y,A[E])end;for E=1,#B do table.insert(y,B[E])end end;z()s("https://raw.githubusercontent.com/HeroBrine1st/OpenComputers/master/TabletOS/lib/gui.lua","/lib/gui.lua")s("https://raw.githubusercontent.com/IgorTimofeev/OpenComputers/master/lib/ECSAPI.lua","/lib/ECSAPI.lua")s("https://raw.githubusercontent.com/IgorTimofeev/OpenComputers/master/lib/advancedLua.lua","/lib/advancedLua.lua")local F=require("gui")local a=require("component")local h=a.gpu;h.setBackground(0xCCCCCC)require("term").clear()l=function(m)local n,o=pcall(a.internet.request,m)if n then local p=""while true do local q,r=o.read()if q then p=p..q;k=k+q:len()F.centerText(i/2,j-1,""..tostring(k).." bytes total")else if r then return false,r else return true,p end end end else return false,reason end end;local G=F.drawButton(20,7,40,11,"Install TabletOS",0xFFFFFF-0xCCCCCC,0xFFFFFF)F.drawProgressBar(1,25,80,0xFF0000,0x00FF00,0,#y)while true do local H,H,I,J,H,H=e.pull("touch")if G(I,J)then break end end;h.fill(1,1,80,24," ")h.setForeground(0xFFFFFF-0xCCCCCC)for E=1,#y do h.fill(1,2,80,22," ")F.centerText(40,13,"Downloading "..y[E].path)s(y[E].url,y[E].path)F.animatedProgressBar(1,25,80,0xFF0000,0x00FF00,E,#y,E-1)end;F.centerText(40,4,"Made by HeroBrine1. github.com/HeroBrine1st vk.com/herobrine1_mcpe")F.centerText(40,5,"https://www.youtube.com/channel/UCYWnftLN1JLhOr0OydR4cUA (https://vk.cc/69QFJN)")F.centerText(40,6,"Installation completed")local K=F.drawButton(20,7,40,11,"Reboot",0xFFFFFF-0xCCCCCC,0xFFFFFF)while true do local H,H,I,J,H,H=e.pull("touch")if K(I,J)then require("computer").shutdown(true)end end
