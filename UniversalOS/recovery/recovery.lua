local filesystem = require("filesystem")
local component = require("component")
local computer = require("computer")
local fs = require("filesystem")
local internet = require("internet")
local shell = require("shell")
local GitHubInstallerUrl = "https://raw.githubusercontent.com/HeroBrine1st/OpenComputers/master/UniversalOS/UOS/install.lua"
local GitHubApplicationsUrl = "https://raw.githubusercontent.com/HeroBrine1st/OpenComputers/master/UniversalOS/UOS/applications.txt"
local gpu =  component.gpu
local event = require("event")
local package = require("package")
local term = require("term")
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
 else
   io.stderr("Can't download " .. url .. "\n")
 end
end
local function dI()
_G.eventInterruptBackup = package.loaded.event.shouldInterrupt 
_G.eventSoftInterruptBackup = package.loaded.event.shouldSoftInterrupt 
package.loaded.event.shouldInterrupt = function () return false end
package.loaded.event.shouldSoftInterrupt = function () return false end
end


local function eI()
if _G.eventInterruptBackup then
package.loaded.event.shouldInterrupt = _G.eventInterruptBackup 
package.loaded.event.shouldSoftInterrupt = _G.eventSoftInterruptBackup
end
end
local w,h = gpu.getResolution()
local function firstMenu()
gpu.setBackground(0xCCCCCC)
gpu.fill(1,1,w,h," ")
gpu.setBackground(0xFFFFFF)
gpu.setForeground(0x000000)
gpu.fill(1,1,w,1," ")
gpu.set(1,3,"Reinstall system")
gpu.setBackground(0xFFFFFF)
gpu.setForeground(0x000000)
gpu.fill(1,3,w,3," ")
gpu.set(1,1,"Reboot system now")
gpu.setForeground(0xFFFFFF)
gpu.setBackground(0xCCCCCC)
gpu.set(1,2,"Repair/update system")
gpu.fill(1,4,w,5," ")
end

local w,h = gpu.getResolution()
local function status(msg)
end

gpu.setBackground(0xCCCCCC)
dI()
gpu.fill(1,1,w,h," ")

--status("Booting recovery")
firstMenu()

while true do
local touch = {event.pull("touch")}
if touch[4]==3 then
gpu.setBackground(0x000000)
term.clear()
dofile("/bin/install.lua")
os.sleep(1)
firstMenu()
end
if touch[4]==1 then
gpu.setBackground(0x000000)
term.clear()
eI()
computer.shutdown(true)
break
end
if touch[4]==2 then
  gpu.setBackground(0x000000)
  term.clear()
  write("Downloading file list...    ")

local success, reason = getFromGitHub("https://raw.githubusercontent.com/HeroBrine1st/OpenComputers/master/UniversalOS/UOS/applications.txt","/UOS/applications.txt")

  
  local applications
  if success == true then
dfile = "return " .. string.gsub(reason,"\n","")
write("Success\n\n")
else
error("Error. Reason: " .. reason)
end

  local file = io.open("/UOS/apps.lua","w") 
  file:write(dfile)
  file:close()
  applications = dofile("/UOS/apps.lua")
  local result = "y"
  io.write("\n")
    if not result or result == "" or result:sub(1, 1):lower() == "y" then
      for i = 1, #applications do
        print("Check " .. applications[i].path)
        local size = fs.size(applications[i].path)
          if fs.exists(applications[i].path) == true then
            local file = io.open(applications[i].path,"r")
            local text = file:read(size+1)
            file:close()
            local success, textOriginal = getFromGitHub(applications[i].url,"/tmp/recovery.tmp")
            if text == textOriginal then
              print(applications[i].path .. " true")
            else
              write("Downloading " .. applications[i].path .. "    ")
              local success, reason = getFromGitHub(applications[i].url,applications[i].path)
              if success == true then
        io.write("Success")
        end
        if success == false then
        io.stderr("error. Reason: " .. reason)
        end
            end
          else
            write("Downloading " .. applications[i].path .. "    ")
              local success, reason =  getFromGitHub(applications[i].url,applications[i].path)
              if success == true then
io.write("Success")
end
if success == false then
io.stderr("Error. Reason: " .. reason)
end
          end
        end
      end
term.clear()
firstMenu()
end  
end
