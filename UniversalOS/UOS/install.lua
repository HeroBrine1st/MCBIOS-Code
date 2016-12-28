local filesystem = require("filesystem")
local component = require("component")
local computer = require("computer")
local fs = require("filesystem")
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
   return success, reason
 end
end

write("Downloading file list    ")
local success, reason = getFromGitHub("https://raw.githubusercontent.com/HeroBrine1st/OpenComputers/master/UniversalOS/UOS/applications.txt","/UOS/applications.txt")

local dfile
local applications
if success == true then
dfile = "return " .. string.gsub(reason,"\n","")
write("Success\n\n")
else
error("Error. Reason: " .. reason)
end
reason = nil
success = nil
local file = io.open("/UOS/apps.lua","w")
file:write(dfile)
file:close()
applications = dofile("/UOS/apps.lua")

for i = 1, #applications do
write("Downloading \"" .. applications[i].name .. "\"...     ")
local success, reason = getFromGitHub(applications[i].url, applications[i].path)
if success == true then
io.write("Success\n")
end
if success == false then
io.stderr("Error. Reason: " .. reason)
end
end

write("\nCheck downloaded files...\n\n")

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
            local success, textOriginal = getFromGitHub(applications[i].url,"/tmp/systemchecker.tmp")
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


  


write("\nInstallation completed!\n")

write("\nReboot now? [Y/n] ")
  local result = read()
  if not result or result == "" or result:sub(1, 1):lower() == "y" then
    write("\nRebooting now!\n")
    computer.shutdown(true)
  end

term.clear()
write("Returning to shell\n")
