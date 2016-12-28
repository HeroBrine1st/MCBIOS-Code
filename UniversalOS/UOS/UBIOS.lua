local pr,cm,ls,ps=component.proxy,computer,component.list,computer.pullSignal

local rom = {}
  function rom.invoke(method, ...)
    return component.invoke(computer.getBootAddress(), method, ...)
  end
  function rom.open(file) return rom.invoke("open", file) end
  function rom.read(handle) return rom.invoke("read", handle, math.huge) end
  function rom.close(handle) return rom.invoke("close", handle) end
  function rom.inits() return ipairs(rom.invoke("list", "boot")) end
  function rom.isDirectory(path) return rom.invoke("isDirectory", path) end

local function loadfile(file)
    local handle, reason = rom.open(file)
    if not handle then
      error(reason)
    end
    local buffer = ""
    repeat
      local data, reason = rom.read(handle)
      if not data and reason then
        error(reason)
      end
      buffer = buffer .. (data or "")
    until not data
    rom.close(handle)
    return load(buffer, "=" .. file)
  end

local function boot(file)
	local loadF, loadR = loadfile(file)
	if loadF then
		local success, reason = pcall(loadF)
		if not success then error((reason ~= nil and tostring(reason) or "unknown error") .. "\n") end
	else 
		error((loadR ~= nil and tostring(loadR) or "unknown error") .. "\n")
	end
end

local gpu = pr(ls("gpu")())
local screen = ls("screen")()
local ee = pr(ls("eeprom")())
if gpu and screen then
gpu.bind(screen)
end

gpu.setBackground(0x000000)
gpu.setForeground(0xFFFFFF)
local w,h = gpu.getResolution()
gpu.fill(1,1,w,h," ")

local function cT(text,y)
	local len = unicode.len(text)
	local x = math.floor(w/2-len/2)
	gpu.set(x,y,text)
end

local function status(msg)
centerText(msg, h/2)
end

cT("UniversalOS",1)
gpu.set(1,1,"Select what to boot")
gpu.set(1,2,"System")
gpu.set(1,3,"Recovery")
local b = 0
while true do
	local signal = {cm.pullSignal()}
	if signal[1] == "touch" then
		if signal[4] == 2 then
			b = 2
		end
		if signal[4] == 3 then 
			b = 3
		end
	end
end

if b == 2 then
	boot(ee.getData(),"/init.lua")
end 
if b == 3 then
	boot(ee.getData(),"/recovery/recovery.init.lua")
end
