local core = {}
local fs = require("filesystem")
local computer = require("computer")
local component = require("component")
local ecs = require("ECSAPI")
local gpu = component.gpu
core.languagePackages = {
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

core.language = "en"

function core.getLanguage()
	local f, r = io.open("/.tabletos","r")
	if f then
		language = f:read(fs.size("/.tabletos")+1)
		f:close()
		return language
	else
		local f = io.open("/.tabletos","w")
		f:write("en")
		f:close()
		return "en"
	end
end

function core.saveLanguage()
	fs.remove("/.tabletos")
	local f = io.open("/.tabletos","w")
	f:write(core.language)
	f:close()
end

function core.changeLanguage(language)
	if language then
		computer.pushSignal("changeLanguage",core.language,language)
		core.language = language
		core.saveLanguage()
	end
end



function core.getLanguagePackages()
	return core.languagePackages[core.getLanguage()]
end

function core.internetRequest(url)
	local success, response = pcall(component.internet.request, url)
	if success then
		local responseData = ""
		while true do
			local data, responseChunk = response.read()
			if data then
				responseData = responseData .. data
			else
				if responseChunk then
					return false, responseChunk
				else
					return true, responseData
				end
			end
		end
	else
		return false, reason
	end
end

function core.getFile(url,filepath)
 local success, reason = core.internetRequest(url)
 if success then
   fs.makeDirectory(fs.path(filepath) or "")
   fs.remove(filepath)
   local file = io.open(filepath, "w")
   if file then
   file:write(reason)
   file:close()
    end
   return reason
 else
   error(reason)
 end
end


function core.downloadFileListAndDownloadFiles(fileListUrl,debug)
	if debug then	
		print("Downloading file list") 
	end
	local success, string = core.getFile(fileListUrl,"/tmp/jdddajsldkasjads.tmp")
	if success then
		local fileListLoader = load("return " .. string)
		local success, fileList = pcall(fileListLoader)
		if success then
			for i = 1, #fileList do
				core.getFile(fileList[i].url,fileList[i].path)
				if debug then 
					print("Downloading " .. fileList[i].path) 
				end
			end
		else 
			error(fileList) 
		end
	else 
		error(string) 
	end
end

function core.saveDisplayAndCallFunction(callback)
local w, h = component.gpu.getResolution()
local oldPixels = ecs.rememberOldPixels(1,1,w,h)
local result = {pcall(callback)}
ecs.drawOldPixels(oldPixels)
return table.unpack(result)
end

core.gui = {}

function core.gui.drawProgressBar(x,y,w,colorEmpty,colorFilled,progress,maxProgress)
colorEmpty = colorEmpty or 0x000000
colorFilled = colorFilled or 0xFFFFFF
progress = progress or 0
maxProgress = maxProgress or 100
local h = 1
local coff = w/maxProgress
local celoe, drobnoe = math.modf(coff*progress)
local progressVCordax
if drobnoe > 0.5 then progressVCordax = celoe+1 else progressVCordax = celoe end
local oldBackground = gpu.setBackground(colorEmpty)
gpu.fill(x,y,w,1," ")
gpu.setBackground(colorFilled)
gpu.fill(x,y,progressVCordax,1," ")
gpu.setBackground(oldBackground)
end

return core
