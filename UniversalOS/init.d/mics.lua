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
buffer.start()

local str ="Booting internal system"
local lenght = (unicode.len(str)/2)
local x1 = w/2-lenght-5
local y1 = h/2-5
local w1 = lenght*2+5
local h1 = 10
buffer.square(x1,y1,w1,h1,0xF3F3F3,0xF3F3F3," ",100)
gpu.setBackground(0x000000)
gpu.set(w/2-lenght,h/2,str)
os.sleep(0.5)
break
end
if touch[4]==3 then
buffer.start()
local str ="Booting recovery"
local lenght = (unicode.len(str)/2)
local x1 = w/2-lenght-5
local y1 = h/2-5
local w1 = lenght*2+5
local h1 = 10
buffer.square(x1,y1,w1,h1,0xF3F3F3,0xF3F3F3," ",100)
gpu.setBackground(0x000000)
gpu.set(w/2-lenght,h/2,str)
os.sleep(0.5)
dofile("/recovery/recovery.lua")
end
end
