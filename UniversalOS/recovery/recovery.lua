local filesystem = require("filesystem")
local component = require("component")
local computer = require("computer")
local fs = require("filesystem")
local internet = require("internet")
local shell = require("shell")
local GitHubInstallerUrl = "https://raw.githubusercontent.com/HeroBrine1st/OpenComputers/master/UniversalOS/UOS/install.lua"
local GitHubApplicationsUrl = "https://raw.githubusercontent.com/HeroBrine1st/OpenComputers/master/UniversalOS/UOS/applications.txt"
local gpu =  component.gpu
local package = require("package")
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
   return reason
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
local function status(msg)
gpu.copy(1,h/3,w,h,w,h-1)
gpu.fill(1,h/3,w,h/3-1)
gpu.set(1,h,msg)
end

gpu.setBackground(0xCCCCCC)
dI()
gpu.fill(1,1,w,h," ")

status("Booting recovery")

local function firstMenu()
gpu.setBackground(0xD8D8D8)
gpu.fill(1,1,w,1)
gpu.set(1,1,"Reinstall system")
gpu.fill(1,3,w,3)
gpu.set(1,3,"Exit")
gpu.setBackground(0xCCCCCC)
gpu.set(1,2,"Repair system")
end

firstMenu()
