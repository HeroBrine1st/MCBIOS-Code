--Интерфейс к fastboot планшета. для включения на планшете - включите и сразу же держите любую кнопку на клавиатуре

local a=require("component")local b=require("computer")local c=a.modem;local d=require("filesystem")if not d.exists("/lib/forms.lua")then os.execute("pastebin get iKzRve2g lib/forms.lua")end;local e=require("forms")local f,g=a.gpu.getResolution()io.write("Enter port:")local h=io.read()h=tonumber(h)local i=e.addForm()local j=i:addButton(1,1,"Repair/update system",function()c.broadcast(h,[[local function internetRequest(url)
  local success, response = pcall(component.proxy(component.list("internet")()).request, url)
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




local function getFile(url,filepath)
  fastboot.print("Downloading " .. filepath)
  local success, reason = internetRequest(url)
  if success then
    filesystem.makeDirectory(filepath .. "dir")
    filesystem.remove(filepath .. "dir")
    filesystem.remove(filepath)
    local file = filesystem.open(filepath, "w")
    if file then
    filesystem.write(file,reason)
    filesystem.close(file)
    end
  else
    error(reason)
  end
end

fastboot.print("Downloading file list    ")

local success1, string = internetRequest("https://raw.githubusercontent.com/HeroBrine1st/OpenComputers/master/TabletOS/applications.txt")
if not success1 then error(string) end
local downloads = load("return" .. string,"=filelistloader")()




for i = 1, #downloads do
getFile(downloads[i].url,downloads[i].path)
end]])end)j.W=f;local k=i:addButton(1,2,"Uninstall OS",function()c.broadcast(h,[[local function internetRequest(url)
  local success, response = pcall(component.proxy(component.list("internet")()).request, url)
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




fastboot.print("Uninstalling OS...")
fastboot.print("Downloading file list    ")

local success1, string = internetRequest("https://raw.githubusercontent.com/HeroBrine1st/OpenComputers/master/TabletOS/applications.txt")
if not success1 then error(string) end
local downloads = load("return" .. string,"=filelistloader")()




for i = 1,#downloads do
	fastboot.print("Deleting " .. downloads[i].path)
	filesystem.remove(downloads[i].path)
end

local function getFile(url,filepath)
  fastboot.print("Downloading " .. filepath)
  local success, reason = internetRequest(url)
  if success then
    filesystem.makeDirectory(filepath .. "dir")
    filesystem.remove(filepath .. "dir")
    filesystem.remove(filepath)
    local file = filesystem.open(filepath, "w")
    if file then
    filesystem.write(file,reason)
    filesystem.close(file)
    end
  else
    error(reason)
  end
end

getFile("https://raw.githubusercontent.com/HeroBrine1st/OpenComputers/master/TabletOS/initBackup.lua","init.lua")

]])end)k.W=f;e.run(i)
