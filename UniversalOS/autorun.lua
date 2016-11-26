local component = require("component")
local gpu = component.gpu
local unicode = require("unicode")
local w,h = gpu.getResolution()
local function centerText(y, text)
      local lenght = unicode.len(text)
      local x = math.floor(w / 2 - lenght / 2)
      gpu.set(x,y,text)
  end
gpu.setBackground(0x000000)
gpu.setForeground(0xFFFFFF)
gpu.fill(1,1,w,h," ")
centerText(h/2-1,"UniversalOS")
centerText(h/2,"Booting system")

local function status(msg)
gpu.setForeground(0x434343)
gpu.set(1,h,msg)
gpu.setForeground(0xFFFFFF)
end

status("Test")

os.sleep(1)
