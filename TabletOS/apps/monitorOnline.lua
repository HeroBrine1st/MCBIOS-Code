local computer = require("computer")
local component = require("component")
local gpu = component.gpu
local event = require("event")
local fs = require("filesystem")
local ecs = require("ECSAPI")
local term = require("term")
local unicode = require("unicode")
local Math = math
local function requirePlayer(name)
local online, reason = computer.addUser(name)
computer.removeUser(name)
return online, reason
end
term.setCursor(1,2)
io.write(languagePackages[language].enterNickname)
local nickname = io.read()
while true do
local online = requirePlayer(nickname)
local str
if online then
str = "Online"
computer.beep(500,0.5)
else
str="Offline"
end
gpu.fill(1,2,80,23," ")
gpu.set(1,2,str)
os.sleep(0.1)
end
