local computer = require("computer")
local component = require("component")
local gpu = component.gpu
local event = require("event")
local fs = require("filesystem")
local ecs = require("ECSAPI")
local term = require("term")
local unicode = require("unicode")
local zygote = require("zygote")
local Math = math
local apps = {}
local shell =  require("shell")
term.clear()
local w,h = gpu.getResolution()
local function drawBar()
gpu.setBackground(0x610B5E)
gpu.fill(1,25,80,1," ")
gpu.set(40,25,"●")
gpu.set(35,25,"◀")
gpu.set(45,25,"▶")
gpu.setBackground(0xFFFF00)
gpu.setForeground(0x610B5E)
gpu.set(1,25,"M")
gpu.setBackground(0x000000)
gpu.setForeground(0xFFFFFF)
end
local language = "en"

local f, r = io.open("/.tabletos","r")
if f then
	language = f:read(fs.size("/.tabletos")+1)
	f:close()
end
local languagePackages = {
	en={
	settings="Settings",
	shutdown="Shutdown",
	reboot="Reboot",
	language="Language",
	selLanguage="Select language",
	monitorOnline="Monitor",
	enterNickname="Enter nickname:",
	logout="Logout",
	shutdownI="Shutting down",
	},
	ru={
	settings="Настройки",
	shutdown="Выключить",
	reboot="Перезагрузить",
	language="Язык",
	selLanguage="Выберите язык",
	monitorOnline="Монитор",
	enterNickname="Введите никнейм игрока:",
	logout="Завершение сеанса",
	shutdownI="Завершение работы",
	}
}
local function saveSettings()
	fs.remove("/.tabletos")
	local f = io.open("/.tabletos","w")
	f:write(language)
	f:close()
end

local oldPixels = {}
local function drawMenu()
oldPixels = ecs.rememberOldPixels(1,10,15,24)
	local oldb = gpu.setBackground(0xFFFFFF)
	local oldf = gpu.setForeground(0x000000)

	gpu.fill(1,10,15,15," ")
	gpu.set(1,24,languagePackages[language].shutdown)
	gpu.set(1,23,languagePackages[language].reboot)
	gpu.set(1,22,languagePackages[language].settings)
	gpu.set(1,21,languagePackages[language].monitorOnline)
	gpu.setForeground(oldf)
	gpu.setBackground(oldb)
end


local function clickedAtArea(x,y,x2,y2,touchX,touchY)
if (touchX >= x) and (touchX <= x2) and (touchY >= y) and (touchY <= y2) then 
return true 
end 
return false
end

local function shutdown(reboot)
local computer = require("computer")
local component = require("component")
local gpu = component.gpu
local function centerText(y,text)
local x = Math.floor(w/2-unicode.len(text)/2)
gpu.set(x,y,text)
end
gpu.setBackground(0x0000FF)
gpu.fill(1,1,w,h," ")
centerText(h/2,languagePackages[language].logout)
saveSettings()
languagePackages = nil
apps = nil
language = nil
_G = nil
io = nil
os = nil
package = nil
gpu.fill(1,1,80,25," ")
centerText(h/2,languagePackages[language].shutdownI)
os.sleep(0.4)
computer.shutdown(reboot)
end

local function startClickListenerM()
	while true do
		local touch = {event.pull("touch")}
		if clickedAtArea(1,10,15,24,touch[3],touch[4]) then
			if touch[4] == 24 then
				shutdown()
			elseif touch[4] == 23 then
				shutdown(true)
			elseif touch[4] == 22 then
				apps.settings()
				gpu.setBackground(0x610B5E)
				gpu.setForeground(0xFFFFFF)
				gpu.fill(1,1,70,1," ")
				gpu.setBackground(0x000000)
				gpu.fill(1,2,80,23," ")
				break
			elseif touch[4] == 21 then
				dofile("/apps/monitorOnline.lua")
				gpu.setBackground(0x610B5E)
				gpu.setForeground(0xFFFFFF)
				gpu.fill(1,1,70,1," ")
				gpu.setBackground(0x000000)
				gpu.fill(1,2,80,23," ")
				break
			end
		else
			gpu.setForeground(0xFFFFFF)
			gpu.setBackground(0x000000)
			gpu.fill(1,10,10,15," ")
			ecs.drawOldPixels(oldPixels)
			oldPixels = {}
			break
		end
	end
end

local function centerText(y,text)
local x = Math.floor(w/2-unicode.len(text)/2)
gpu.set(x,y,text)
end



function apps.settings()
gpu.setBackground(0x610B5E)
gpu.setForeground(0xFFFFFF)
gpu.set(1,1,languagePackages[language].settings)
gpu.setBackground(0xCCCCCC)
gpu.fill(1,2,80,23," ")
gpu.setForeground(0xFFFFFF)
gpu.set(1,2,languagePackages[language].language)
local oldPixelsSettings = {}
local doReturn = false
	local function selectLanguage()
		oldPixelsSettings = ecs.rememberOldPixels(1,2,80,24)
		gpu.setBackground(0xCCCCCC)
		gpu.setForeground(0xFFFFFF)
		gpu.fill(1,2,80,23," ")
		centerText(2,languagePackages[language].selLanguage)
		centerText(3,"English")
		centerText(4,"Русский")
		while true do
			local touch = {event.pull("touch")}
			if touch[4] == 3 then
				language = "en"
				gpu.setBackground(0x610B5E)
				gpu.setForeground(0xFFFFFF)
				gpu.fill(1,1,70,1," ")
				gpu.set(1,1,languagePackages[language].settings)
				gpu.setBackground(0xCCCCCC)
				gpu.fill(1,2,80,23," ")
				gpu.setForeground(0xFFFFFF)
				gpu.set(1,2,languagePackages[language].language)
				break
			elseif touch[4] == 4 then
				language = "ru"
				gpu.setBackground(0x610B5E)
				gpu.setForeground(0xFFFFFF)
				gpu.fill(1,1,70,1," ")
				gpu.set(1,1,languagePackages[language].settings)
				gpu.setBackground(0xCCCCCC)
				gpu.fill(1,2,80,23," ")
				gpu.setForeground(0xFFFFFF)
				gpu.set(1,2,languagePackages[language].language)
				ecs.drawOldPixels(oldPixelsSettings)
				break
			elseif touch[3] == 1 and touch[4] == 25 then
				drawMenu()
				startClickListenerM()
			elseif touch[3] == 40 and touch[4] == 25 then
				doReturn = true
				gpu.setBackground(0x610B5E)
				gpu.setForeground(0xFFFFFF)
				gpu.fill(1,1,70,1," ")
				gpu.set(1,1,languagePackages[language].settings)
				gpu.setBackground(0xCCCCCC)
				gpu.fill(1,2,80,23," ")
				gpu.setForeground(0xFFFFFF)
				gpu.set(1,2,languagePackages[language].language)
				ecs.drawOldPixels(oldPixelsSettings)
				break
			elseif touch[3] == 35 and touch[4] == 25 then
				gpu.setBackground(0x610B5E)
				gpu.setForeground(0xFFFFFF)
				gpu.fill(1,1,70,1," ")
				gpu.set(1,1,languagePackages[language].settings)
				gpu.setBackground(0xCCCCCC)
				gpu.fill(1,2,80,23," ")
				gpu.setForeground(0xFFFFFF)
				gpu.set(1,2,languagePackages[language].language)
				ecs.drawOldPixels(oldPixelsSettings)
				break
			end
		end
	end









while true do
	local touch = {event.pull("touch")}
	if touch[3] == 1 and touch[4] == 25 then
		drawMenu()
		startClickListenerM()
	elseif touch[4] == 2 then
		selectLanguage()
		saveSettings()	
	elseif touch[3] == 40 and touch[4] == 25 then
		break
	elseif touch[3] == 35 and touch[4] == 25 then
		break
	end
	if doReturn == true then
		break
	end
end
end




_G.oldEnergy = 100

local function statusBar()
local component = require("component")
local gpu = component.gpu
gpu.setBackground(0x610B5E)
gpu.setForeground(0xFFFFFF)
local energy = Math.floor((computer.energy()/computer.maxEnergy())*100)
local str = string.gsub(string.format("%q",math.floor(computer.energy()/computer.maxEnergy()*100)),"\"","")
local len = Math.floor(unicode.len(str)/2)
gpu.set(79-len,1,str)
gpu.set(80,1,"%")
gpu.setBackground(0x000000)
gpu.setForeground(0xFFFFFF)
if energy < 6 then
require("term").clear()
print("Not enough energy! Shutdown tablet... ")
require("computer").shutdown()
end
if not energy == oldEnergy then
computer.pushSignal("energyChange",oldEnergy,energy)
end
oldEnergy = energy
end
local timerID
local function drawStatusBar()
gpu.setBackground(0x610B5E)
gpu.setForeground(0xFFFFFF)
gpu.fill(1,1,80,1," ")
gpu.setBackground(0x000000)
gpu.setForeground(0xFFFFFF)
timerID = event.timer(1,statusBar,math.huge)
end

drawStatusBar()
drawBar()

local form = zygote.addForm()
form.left=1
form.top=2
form.W=80
form.H=23
form.color=0xCCCCCC

local function setACtiveForm()
form:setActive()
end
local function stopForm(view)
zygote.stop(form)
end
local currentPath = "/"
local button = form:addButton(1,23,"Exit",stopForm)
button.W = 4


local list = form:addList(1,1,function(view)
local value = view.items[view.index]
if fs.isDirectory(value) then
	currentPath = value
	view:clear()
	for name in fs.list(currentPath) do
list:insert(name,currentPath .. name)
end
elseif fs.exists(value) then
local windowForm = zygote.addForm()
windowForm.X = 30
windowForm.Y = 25/2-5
windowForm.W = 20
windowForm.H = 10
windowList = windowForm:addList(30,25/2-5,function(view)
local valueL = view.items[view.index]
if valueL == 0 then
shell.execute("edit " .. value)
elseif valueL == 1 then
shell.execute(value)
elseif valueL == 2 then
fs.remove(value)
end
setACtiveForm()
end)
windowList:insert("Edit",0)
windowList:insert("Execute",1)
windowList:insert("Remove",2)
zygote.run(windowForm)
end
end)
list.W = 80
list.H = 22

for name in fs.list(currentPath) do
list:insert(name,currentPath .. name)
end
while true do
	local touch = {event.pull("touch")}
	if touch[3] == 1 and touch[4] == 25 then
		local oldPixelsM = {}
		oldPixelsM = ecs.rememberOldPixels(1,2,80,24)
		drawMenu()
		startClickListenerM()
		ecs.drawOldPixels(oldPixelsM)
	elseif touch[3] == 45 and touch[4] == 25 then
		event.cancel(timerID)
		term.clear()
		break
	elseif clickedAtArea(1,2,80,24,touch[3],touch[4]) then
		computer.pushSignal(table.unpack(touch))
		zygote.run(form)
	end
end
