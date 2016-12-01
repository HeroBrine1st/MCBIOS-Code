local filesystem = require("filesystem")
local component = require("component")
local computer = require("computer")
local fs = require("filesystem")
local internet = require("internet")
local serialization = require("serialization")
local shell = require("shell")
local event = require("event")
local term = require("term")
local GitHubUrl = "https://raw.githubusercontent.com/"

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
   write("Success \n")
   return reason
 else
   error("Can't download " .. url)
 end
end

print("Downloading file list")
print(" ")
getFromGitHub("https://raw.githubusercontent.com/HeroBrine1st/OpenComputers/master/UniversalOS/UOS/applications.txt","/UOS/applications.txt")

local applications
local dfile = "return " .. string.gsub(getFromGitHub("https://raw.githubusercontent.com/HeroBrine1st/OpenComputers/master/UniversalOS/UOS/applications.txt","/UOS/applications.txt"),"\n","")

local file = io.open("/UOS/apps.lua","w")
file:write(dfile)
file:close()
applications = dofile("/UOS/apps.lua")

for i = 1, #applications do
if applications[i].preLoad == false then
write("Downloading \"" .. applications[i].name .. "\"...     ")
getFromGitHub(applications[i].url, applications[i].path)
end
end

write("\nCheck downloaded files...\n\n")


  print("Downloading file list...")
  local applications
  local dfile = "return " .. string.gsub(getFromGitHub("https://raw.githubusercontent.com/HeroBrine1st/OpenComputers/master/UniversalOS/UOS/applications.txt","/UOS/applications.txt"),"\n","")

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
            local textOriginal = getFromGitHub(applications[i].url,"/tmp/recovery.tmp")
            if text == textOriginal then
              print(applications[i].path .. " true")
            else
              print("Downloading " .. applications[i].path)
              getFromGitHub(applications[i].url,applications[i].path)
            end
          else
            print("Downloading " .. applications[i].path)
              getFromGitHub(applications[i].url,applications[i].path)
          end
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
write("\nReturning to shell\n")
