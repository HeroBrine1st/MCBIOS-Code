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
local oldPixelsM = {}
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
_G.language = "en"

local f, r = io.open("/.tabletos","r")
if f then
	language = f:read(fs.size("/.tabletos")+1)
	f:close()
end
_G.languagePackages = {
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
	newFolder="New folder",
	newFile="New file",
	updateFileList="Update files",
	fileManager="File Manager",
	power="Sleep",
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
	newFolder="Новая папка",
	newFile="Новый файл",
	updateFileList="Обновить",
	fileManager="Файлы",
	power="Сон"
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
	gpu.set(1,20,languagePackages[language].fileManager)
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
apps = nil
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
			elseif touch[4] == 20 then
				ecs.drawOldPixels(oldPixelsM)
				dofile("/apps/fileManager.lua")
				break
			end
		else
			gpu.setForeground(0xFFFFFF)
			gpu.setBackground(0x000000)
			gpu.fill(1,10,10,15," ")
			ecs.drawOldPixels(oldPixels)
			oldPixels = {}
			computer.pushSignal(table.unpack(touch))
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
local power = languagePackages[language].power
local len = unicode.len(power)
gpu.setBackground(0xFFFF00)
gpu.setForeground(0x610B5E)
gpu.set(1,76-len,power)
gpu.setBackground(0x000000)
gpu.setForeground(0xFFFFFF)
timerID = event.timer(1,statusBar,math.huge)
end

drawStatusBar()
drawBar()




while true do
	local touch = {event.pull("touch")}
	if touch[3] == 1 and touch[4] == 25 then
		
		oldPixelsM = ecs.rememberOldPixels(1,2,80,24)
		drawMenu()
		startClickListenerM()
		ecs.drawOldPixels(oldPixelsM)
	elseif touch[3] == 45 and touch[4] == 25 then
		event.cancel(timerID)
		term.clear()
		break
	end
end
