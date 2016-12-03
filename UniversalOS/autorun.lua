_G.component = require("component")
_G.computer = require("computer")
_G.unicode = require("unicode")
_G.gpu = component.gpu

local function list(dir)
local component = require("component")
local fs = require("filesystem")
local shell = require("shell")
local text = require('text')
 

  local list, reason = fs.list(path)
    local lsd = {}
    local lsf = {}
    local m = 1
    for f in list do
      m = math.max(m, f:len() + 2)
      if f:sub(-1) == "/" then
        if options.p then
          table.insert(lsd, f)
        else
          table.insert(lsd, f:sub(1, -2))
        end
      else
        table.insert(lsf, f)
      end
    end
    table.sort(lsd)
    table.sort(lsf)
   return lsf
end

local initdList = list("/init.d/")
for i = 0, #initdList do
dofile("/init.d/" .. initdList[i])
end


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










status("Booting " .. _OSVERSION)

os.sleep(4) 

gpu.fill(1,1,w,h," ")
require("term").clear()
