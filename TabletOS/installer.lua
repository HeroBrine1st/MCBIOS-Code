local filesystem = require("filesystem")
local component = require("component")
local computer = require("computer")
local fs = require("filesystem")
local shell = require("shell")
local event = require("event")
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
    print("")
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

local function sortTable()
local apps, libraries, other = {}, {}, {}
local applications = downloads
for i = 1, #applications do
if string.gsub(fs.path(applications[i].path),"/","") == "apps" then
  table.insert(apps,applications[i])
elseif string.gsub(fs.path(applications[i].path),"/","") == "lib" then
  table.insert(libraries,applications[i])
else 
  table.insert(other,applications[i])
end
end
downloads = {}
for i = 1, #other do
  table.insert(downloads,other[i])
end
for i = 1, #apps do
  table.insert(downloads,apps[i])
end
for i = 1, #libraries do
  table.insert(downloads,libraries[i])
end
end
sortTable()

getFile("https://raw.githubusercontent.com/HeroBrine1st/OpenComputers/master/TabletOS/lib/gui.lua","/lib/gui.lua")
local gui = require("gui")
local component = require("component")
local gpu = component.gpu
gpu.setBackground(0xCCCCCC)
require("term").clear()

local speedTestUrl = "https://raw.githubusercontent.com/HeroBrine1st/OpenComputers/master/unnamed.txt"
local function getInternetSpeed()
local uptime = computer.uptime()
internetRequest(speedTestUrl)
local time = computer.uptime() - uptime
local speed = 1024/time
gui.drawProgressBar(1,1,80,0xFF0000,0x00FF00,speed,100000)
local ob = gpu.setBackground(0x00FF00)
gpu.set(1,1,"0")
gpu.setBackground(0xFF0000)
gpu.set(73,1,"100 000")
gui.centerText(40,1,tostring(math.floor(speed)) .. " byte/sec")
gpu.setBackground(ob)
end
local checkTouch1 = gui.drawButton(20,7,40,11,"Install TabletOS",0xFFFFFF-0xCCCCCC,0xFFFFFF)
gui.drawProgressBar(1,25,80,0xFF0000,0x00FF00,0,#downloads)
while true do
  local _, _, x, y, _, _ = event.pull("touch")
  if checkTouch1(x,y) then break end
end
gpu.fill(1,1,80,24," ")
gpu.setForeground(0xFFFFFF-0xCCCCCC)
require("event").timer(0.5,getInternetSpeed,math.huge)
for i = 1, #downloads do
gpu.fill(1,2,80,22," ")
gui.centerText(40,13,"Downloading " .. downloads[i].path)
getFile(downloads[i].url,downloads[i].path)
gui.animatedProgressBar(1,25,80,0xFF0000,0x00FF00,i,#downloads,i-1)
end

gui.centerText(40,4,"Made by HeroBrine1. github.com/HeroBrine1st vk.com/herobrine1_mcpe")
gui.centerText(40,5,"https://www.youtube.com/channel/UCYWnftLN1JLhOr0OydR4cUA (https://vk.cc/69QFJN)")
gui.centerText(40,6,"Installation completed")
local checkTouch2 = gui.drawButton(20,7,40,11,"Reboot",0xFFFFFF-0xCCCCCC,0xFFFFFF)

while true do
  local _, _, x, y, _, _ = event.pull("touch")
  if checkTouch2(x,y) then require("computer").shutdown(true) end
end
