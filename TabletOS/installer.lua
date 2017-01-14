local filesystem = require("filesystem")
local component = require("component")
local computer = require("computer")
local fs = require("filesystem")
local serialization = require("serialization")
local shell = require("shell")
local EEPROMCode
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
   return reason
 else
   error("error")
 end
end

local downloads = {
  {
  url="https://raw.githubusercontent.com/HeroBrine1st/OpenComputers/master/TabletOS/autorun.lua",
  path="/autorun.lua",
},
{
  url="https://raw.githubusercontent.com/IgorTimofeev/OpenComputers/master/lib/ECSAPI.lua",
  path="/lib/ECSAPI.lua",
},
{
  url="https://raw.githubusercontent.com/HeroBrine1st/OpenComputers/master/TabletOS/apps/monitorOnline.lua",
  path="/apps/monitorOnline.lua"
},
{
  url="https://raw.githubusercontent.com/HeroBrine1st/OpenComputers/master/TabletOS/lib/zygote.lua",
  path="/lib/zygote.lua",
}
}

for i = 1, #downloads do
print("Downloading " .. downloads[i].path)
getFromGitHub(downloads[i].url,downloads[i].path)
end

print("Made by HeroBrine1. vk.com/herobrine1_mcpe")
