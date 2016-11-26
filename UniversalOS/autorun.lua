local component = require("component")
local gpu = component.gpu
local unicode = require("unicode")
local w,h = gpu.getResolution()
local function centerText(y, text, color)
      local lenght = unicode.len(text)
      local x = math.floor(w / 2 - lenght / 2)
      local oldcolor = gpu.setForeground(color)
      gpu.set(x,y,text)
      gpu.setForeground(oldcolor)
  end

gpu.fill(1,1,w,h," ")
centerText(w/2,"Booting system",0xFFFFFF)

local function status(msg)
--gpu.setForeground(0x071910)
gpu.set(1,h,msg)
--gpu.setForeground(0xFFFFFF)
end

status("Test")

os.sleep(1)
