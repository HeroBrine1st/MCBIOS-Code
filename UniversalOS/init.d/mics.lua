local event = require("event")

local function firstMenu()
term.clear()
gpu.setBackground(0xCCCCCC)
local w,h = gpu.getResolution()
gpu.fill(1,1,w,h," ")
gpu.setBackground(0xFFFFFF)
gpu.setForeground(0x000000)
gpu.fill(1,1,w,1," ")
gpu.set(1,1,"Select what to boot:")
gpu.setForeground(0xFFFFFF)
gpu.setBackground(0xCCCCCC)
gpu.set(1,2,"System")
gpu.setBackground(0xFFFFFF)
gpu.setForeground(0x000000)
gpu.fill(1,3,w,3," ")
gpu.set(1,3,"Recovery")

gpu.setBackground(0xCCCCCC)
gpu.setForeground(0x000000)
gpu.fill(1,4,w,h," ")
end
firstMenu()
local w,h = gpu.getResolution()
while true do
local touch = {event.pull("touch")}
if touch[4]==2 then
local str ="Booting internal system"
gpu.setBackground(0x000000)
gpu.set(w/2-lenght,h/2,str)
os.sleep(0.5)
break
end
if touch[4]==3 then
local str ="Booting recovery"
local lenght = (unicode.len(str)/2)
gpu.set(w/2-lenght,h/2,str)
os.sleep(0.5)
dofile("/recovery/recovery.lua")
end
end
