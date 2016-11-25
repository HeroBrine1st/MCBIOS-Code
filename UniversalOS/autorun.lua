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


function bootanimation()
local progressBar11 = "." 
local progressBar12 = " " 
local progressBar13 = "."
local progressBar21 = " "
local progressBar22 = "."
local progressBar23 = " "
while true do
centerText(w/2-1,progressBar11,0xFFFFFF)
centerText(w/2,progressBar12,0xFFFFFF)
centerText(w/2+1,progressBar13,0xFFFFFF)
os.sleep(0.1)
centerText(w/2-1,progressBar21,0xFFFFFF)
centerText(w/2,progressBar22,0xFFFFFF)
centerText(w/2+1,progressBar23,0xFFFFFF)
os.sleep(0.1)
end
end

bootanimation()
