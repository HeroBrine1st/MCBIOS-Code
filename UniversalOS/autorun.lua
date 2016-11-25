local component = require("component")
local gpu = component.gpu

local w,h = gpu.getResolution()

local function centerText(y, text, color)
      local lenght = unicode.len(text)
      local x = math.floor(w / 2 - lenght / 2)
      local oldcolor = gpu.setForeground(color)
      gpu.set(x,y,text)
      gpu.setForeground(oldcolor)
  end


print("3")
os.sleep(1)
print("2")
os.sleep(1)
print("1")
os.sleep(1)
require("term").clear()

