local filesystem = require("filesystem")
local component = require("component")
local computer = require("computer")
local fs = require("filesystem")
local serialization = require("serialization")
local shell = require("shell")
local event = require("event")
local term = require("term")
local gpu = component.gpu
local unicode = require("unicode")
local w,h = gpu.maxResolution()
gpu.setResolution(w,h)
local GitHubUrl = "https://raw.githubusercontent.com/"
term.clear()

print("Проверка на соответствие системным требованиям")
print(" ")

local array = {}

if computer.totalMemory()/1024 < 2048 then table.insert(array,"UOS требуется 2048 КБ оперативной памяти") end
if component.isAvailable("tablet") then table.insert(array,"UOS не поддерживает планшеты") end
if w < 150 then table.insert(array,"UOS необходимы экран и видеокарта 3го уровня") end
if fs.get("/").isReadOnly() then table.insert(array,"Установите OpenOS на жёсткий диск перед установкой UOS") end

if #array > 0 then
for i = 1, #array do print(array[i]) end
return
end

local function internetRequest(url)
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
 local write = io.write
local read = io.read



local function getFromGitHub(url,filepath)
 local success, reason = internetRequest(url)
 if success then
   fs.makeDirectory(fs.path(filepath) or "")
   fs.remove(filepath)
   local file = io.open(filepath, "w")
   file:write(reason)
   file:close()
   return success, reason
 end
end

write("Загрузка таблицы файлов    ")
local success, reason = getFromGitHub("https://raw.githubusercontent.com/HeroBrine1st/OpenComputers/master/UniversalOS/UOS/applications.txt","/UOS/applications.txt")

local dfile
local applications
if success == true then
dfile = "return " .. string.gsub(reason,"\n","")
write("Успешно\n\n")
else
error(reason)
end
reason = nil
success = nil
local file = io.open("/UOS/apps.lua","w")
file:write(dfile)
file:close()
applications = dofile("/UOS/apps.lua")

for i = 1, #applications do
  if applications[i].preLoad == true then
    write("Загрузка \"" .. applications[i].name .. "\"...     ")
    local success, reason = getFromGitHub(applications[i].url, applications[i].path)
    if success == true then
      io.write("Успешно\n")
    else
      io.stderr:write("Ошибка: " .. reason .. "\n")
    end
  end
end

local image = require("image")
local api = require("HB1API")
term.clear()
gpu.set(1,1,"Установить UniversalOS?")
gpu.set(1,2,"Установить")
gpu.set(1,3,"Не устанавливать")
while true do
local touch = {event.pull("touch")}
if touch[4] == 2 then
break
elseif touch[4]==3 then
term.clear()
write("Returning to shell\n")
return
end
end

for i = 1, #applications do
  write("Загрузка \"" .. applications[i].name .. "\"...     ")
  local success, reason = getFromGitHub(applications[i].url, applications[i].path)
  if success == true then
    io.write("Успешно\n")
  else
    io.stderr:write("Ошибка: " .. reason .. "\n")
  end
end

write("\nInstallation completed!\n")

write("\nReboot now? [Y/n] ")
  local result = read()
  if not result or result == "" or result:sub(1, 1):lower() == "y" then
    write("\nRebooting now!\n")
    computer.shutdown(true)
  end

term.clear()
write("Returning to shell\n")
