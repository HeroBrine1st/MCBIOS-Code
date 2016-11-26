local component = require("component")
local gpu = component.gpu
local unicode = require("unicode")
local w,h = gpu.getResolution()
local thread = require("Thread")
thread.init()
local function centerText(y, text, color)
      local lenght = unicode.len(text)
      local x = math.floor(w / 2 - lenght / 2)
      local oldcolor = gpu.setForeground(color)
      gpu.set(x,y,text)
      gpu.setForeground(oldcolor)
  end


function boot()
local function centerText(y, text, color)
      local lenght = unicode.len(text)
      local x = math.floor(w / 2 - lenght / 2)
      local oldcolor = gpu.setForeground(color)
      gpu.set(x,y,text)
      gpu.setForeground(oldcolor)
  end
while true do
centerText(w/2,"Booting system",0xFFFFFF)
os.sleep(1)
centerText(w/2,"Booting system.",0xFFFFFF)
os.sleep(1)
centerText(w/2,"Booting system..",0xFFFFFF)
os.sleep(1)
centerText(w/2,"Booting system...",0xFFFFFF)
os.sleep(1)
end
end


thread.create(boot())
