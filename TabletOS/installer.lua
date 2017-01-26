local filesystem = require("filesystem")
local component = require("component")
local computer = require("computer")
local fs = require("filesystem")
local serialization = require("serialization")
local shell = require("shell")

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
local gpu = component.gpu
local w,h = gpu.maxResolution()
if w > 80 or w < 80 then 
  print("TabletOS requires resolution 80,25.") 
  return
end


local function getFile(url,filepath)
 local success, reason = internetRequest(url)
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

io.write("Downloading file list    ")
local uptime = computer.uptime()
local success, downloads = pcall(load("return" .. getFile("https://raw.githubusercontent.com/HeroBrine1st/OpenComputers/master/TabletOS/applications.txt","/tmp/1.tmp")))
if not success then
io.stderr:write("Failed. Total time: " .. tostring(computer.uptime()-uptime) .. " Reason: " .. reason .. "\n")
return
end
io.write("Success. Total time: " .. tostring(computer.uptime()-uptime) .. "\n")
--getFile("https://raw.githubusercontent.com/HeroBrine1st/OpenComputers/master/TabletOS/lib/zygote.lua","/lib/zygote.lua")


--local zygote = require("zygote")


for i = 1, #downloads do
print("Downloading " .. downloads[i].path)
getFile(downloads[i].url,downloads[i].path)
end

print("Made by HeroBrine1. vk.com/herobrine1_mcpe")
