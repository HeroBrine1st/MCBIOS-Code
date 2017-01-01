local component_invoke = component.invoke
function boot_invoke(address, method, ...)
  local result = table.pack(pcall(component_invoke, address, method, ...))
  if not result[1] then
    return nil, result[2]
  else
    return table.unpack(result, 2, result.n)
  end
end
local gpu = component.proxy(component.list("gpu")())
local function err(msg)
  local Math = math
local gp = component.proxy(component.list("gpu")())
gp.setResolution(40,12)
gp.setBackground(0x0000FF)
local w,h = gp.getResolution()
gp.fill(1,1,w,h," ")
gp.set(8,3,":(")
local str = "Your PC ran into a problem and needs to restart. We're just collecting some error info, and then we'll restart for you."
gp.set(8,4,string.sub(str,1,27))
gp.set(8,5,string.sub(str,28,55))
gp.set(8,6,string.sub(str,56,82))
gp.set(8,7,string.sub(str,83,110))
gp.set(8,8,string.sub(str,112,138))
gp.set(8,10,"Error code: " .. string.sub(msg,1,16))
gp.set(8,11,string.sub(msg,17))

while true do
computer.pullSignal()
end
end

local eeprom = component.list("eeprom")()
computer.getBootAddress = function()
  return boot_invoke(eeprom, "getData")
end
computer.setBootAddress = function(address)
  return boot_invoke(eeprom, "setData", address)
end
 
do
  local screen = component.list("screen")()
  local gpu = component.list("gpu")()
  if gpu and screen then
    boot_invoke(gpu, "bind", screen)
  end
end
local function tryLoadFrom(address)
  local handle, reason = boot_invoke(address, "open", "/init.lua")
  if not handle then
    return nil, reason
  end
  local buffer = ""
  repeat
    local data, reason = boot_invoke(address, "read", handle, math.huge)
    if not data and reason then
      return nil, reason
    end
    buffer = buffer .. (data or "")
  until not data
  boot_invoke(address, "close", handle)
  return load(buffer, "=init")
end
local init, reason
if computer.getBootAddress() then
  init, reason = tryLoadFrom(computer.getBootAddress())
end
if not init then
  computer.setBootAddress()
  for address in component.list("filesystem") do
    init, reason = tryLoadFrom(address)
    if init then
      computer.setBootAddress(address)
      break
    end
  end
end
if not init then
  err("no bootable medium found" .. (reason and (": " .. tostring(reason)) or ""), 0)
end
computer.beep(1000, 0.2)
local success, reason = pcall(init)
if not success then
  err(reason)
end
