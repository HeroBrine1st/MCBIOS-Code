local component_invoke = component.invoke
function boot_invoke(address, method, ...)
  local result = table.pack(pcall(component_invoke, address, method, ...))
  if not result[1] then
    return nil, result[2]
  else
    return table.unpack(result, 2, result.n)
  end
end

local gpu = component.list("gpu", true)()
local w, h
  if gpu and screen then
    component.invoke(gpu, "bind", screen)
    w, h = component.invoke(gpu, "getResolution")
    component.invoke(gpu, "setResolution", w, h)
    component.invoke(gpu, "setBackground", 0x000000)
    component.invoke(gpu, "setForeground", 0xFFFFFF)
    component.invoke(gpu, "fill", 1, 1, w, h, " ")
  end

w, h = boot_invoke(gpu,"getResolution")
boot_invoke(gpu,"setBackground",0x000000)
boot_invoke(gpu,"fill",1,1,w,h," ")



do
  _G._OSVERSION = "UniversalOS"

  local component = component
  local computer = computer
  local unicode = unicode

  -- Runlevel information.
  local runlevel, shutdown = "S", computer.shutdown
  computer.runlevel = function() return runlevel end
  computer.shutdown = function(reboot)
    runlevel = reboot and 6 or 0
    if os.sleep then
      computer.pushSignal("shutdown")
      os.sleep(0.1) -- Allow shutdown processing.
    end
    shutdown(reboot)
  end

  -- Low level dofile implementation to read filesystem libraries.
  local rom = {}
  function rom.invoke(method, ...)
    return component.invoke(computer.getBootAddress(), method, ...)
  end
  function rom.open(file) return rom.invoke("open", file) end
  function rom.read(handle) return rom.invoke("read", handle, math.huge) end
  function rom.close(handle) return rom.invoke("close", handle) end
  function rom.inits() return ipairs(rom.invoke("list", "boot")) end
  function rom.isDirectory(path) return rom.invoke("isDirectory", path) end

  local screen = component.list('screen', true)()
  for address in component.list('screen', true) do
    if #component.invoke(address, 'getKeyboards') > 0 then
      screen = address
    end
  end


  
  local y = 1
  local function status(msg)
 return msg
  end

  status("Booting " .. _OSVERSION .. "...")

  -- Custom low-level loadfile/dofile implementation reading from our ROM.
  local function loadfile(file)
    status("> " .. file)
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

  local function dofile(file)
    local program, reason = loadfile(file)
    if program then
      local result = table.pack(pcall(program))
      if result[1] then
        return table.unpack(result, 2, result.n)
      else
        error(result[2])
      end
    else
      error(reason)
    end
  end

local component_invoke = component.invoke
function boot_invoke(address, method, ...)
  local result = table.pack(pcall(component_invoke, address, method, ...))
  if not result[1] then
    return nil, result[2]
  else
    return table.unpack(result, 2, result.n)
  end
end

local gpu = component.list("gpu", true)()
local w, h
  if gpu and screen then
    component.invoke(gpu, "bind", screen)
    w, h = component.invoke(gpu, "getResolution")
    component.invoke(gpu, "setResolution", w, h)
    component.invoke(gpu, "setBackground", 0x000000)
    component.invoke(gpu, "setForeground", 0xFFFFFF)
    component.invoke(gpu, "fill", 1, 1, w, h, " ")
  end

w, h = boot_invoke(gpu,"getResolution")
boot_invoke(gpu,"setBackground",0x000000)
boot_invoke(gpu,"fill",1,1,w,h," ")




  
local function centerText(y, text, color)
  local lenght = unicode.len(text)
  local x = math.floor(w / 2 - lenght / 2)
  local oldcolors
  if color then
    oldcolors = boot_invoke(gpu,"getForeground")
    boot_invoke(gpu, "setForeground", color)
  end
    boot_invoke(gpu, "set", x, y, text)
  if color then
    boot_invoke(gpu, "setForeground", oldcolors)
  end
  end

local function pullFilteredSignal(name)
local result
while true do
local signal = {computer.pullSignal()}
if signal[1] == name then
result = signal
break
end
end
return result
end



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

local function mics()
  local gpu = component.proxy(component.list("gpu")())
  gpu.set(1,1,"Select what to boot")
  gpu.set(1,2,"System")
  gpu.set(1,3,"Recovery")
  while true do
    local touch = pullFilteredSignal("touch")
    if touch[4] == 2 then
      centerText(h/2,"Booting system")
      break
    end
    if touch[4] == 3 then
      centerText(h/2,"Booting recovery")
      while true do
        local recovery, reason = loadfile("/recovery/recovery.init.lua")
        if recovery then
          local result, reason = pcall(recovery)
          if reason then
            err(reason)
          end
        end
        if reason then
          err(reason)
        end
      end
    end
  end
end
do
local success, reason = pcall(mics)
if not success then
boot_invoke(gpu,"set",1,1,reason)
end
end
w, h = boot_invoke(gpu,"getResolution")
centerText(h/2-1,"UniversalOS",0xFFFFFF)
centerText(h/2,"Booting kernel...",0xFFFFFF)

  status("Initializing package management...")

  -- Load file system related libraries we need to load other stuff moree
  -- comfortably. This is basically wrapper stuff for the file streams
  -- provided by the filesystem components.
  local package = dofile("/lib/package.lua")

  do
    -- Unclutter global namespace now that we have the package module.
    _G.component = nil
    _G.computer = nil
    _G.process = nil
    _G.unicode = nil

    -- Initialize the package module with some of our own APIs.
    package.preload["buffer"] = loadfile("/lib/buffer.lua")
    package.preload["component"] = function() return component end
    package.preload["computer"] = function() return computer end
    package.preload["filesystem"] = loadfile("/lib/filesystem.lua")
    package.preload["io"] = loadfile("/lib/io.lua")
    package.preload["unicode"] = function() return unicode end

    -- Inject the package and io modules into the global namespace, as in Lua.
    _G.package = package
    _G.io = require("io")
  end

  status("Initializing file system...")

  -- Mount the ROM and temporary file systems to allow working on the file
  -- system module from this point on.
  local filesystem = require("filesystem")
  filesystem.mount(computer.getBootAddress(), "/")

  status("Running boot scripts...")

  -- Run library startup scripts. These mostly initialize event handlers.
  local scripts = {}
  for _, file in rom.inits() do
    local path = "boot/" .. file
    if not rom.isDirectory(path) then
      table.insert(scripts, path)
    end
  end
  table.sort(scripts)
  for i = 1, #scripts do
    dofile(scripts[i])
  end

  status("Initializing components...")

  local primaries = {}
  for c, t in component.list() do
    local s = component.slot(c)
    if not primaries[t] or (s >= 0 and s < primaries[t].slot) then
      primaries[t] = {address=c, slot=s}
    end
    computer.pushSignal("component_added", c, t)
  end
  for t, c in pairs(primaries) do
    component.setPrimary(t, c.address)
  end
  os.sleep(0.5) -- Allow signal processing by libraries.
  computer.pushSignal("init") -- so libs know components are initialized.

  status("Initializing system...")
  os.error = function(msg)
  local Math = math
local gp = component.proxy(component.list("gpu")())
gp.setResolution(40,12)
gp.setBackground(0x0000FF)
local w,h = gp.getResolution()
gp.fill(1,1,w,h," ")
gp.set(8,3,":(")
local str = "Your PC ran into a problem and needs to restart. We're just collecting some error info, and then we'll restart for you. (0%)"
gp.set(8,4,string.sub(str,1,27))
gp.set(8,5,string.sub(str,28,55))
gp.set(8,6,string.sub(str,56,82))
gp.set(8,7,string.sub(str,83,110))
gp.set(8,8,string.sub(str,112,138))
gp.set(8,10,"Error code: " .. string.sub(msg,1,16))
gp.set(8,11,string.sub(msg,17))
for i = 0, 80 do
gp.set(8,8,"for you. (" .. i .. ")")
end
local fs = require("filesystem")
fs.makeDirectory("/BSoD-logs/")
local date = os.date("!t")
local file = io.open("/BSoD-logs/bsod-"..date.day.."."..date.month.."."..date.year.."-"..date.hour.."."..date.min.."."..date.sec..".log")
file:write("BSoD log\nYour PC ran into a problem. Error code: "..msg)
gp.set(8,8,"for you. (100%). Rebooting...")
os.sleep(0.2)
require("computer").shutdown(true)
end
  require("term").clear()
  os.sleep(0.1) -- Allow init processing.
  runlevel = 1
end

local function motd()
  local f = io.open("/etc/motd")
  if not f then
    return
  end
  if f:read(2) == "#!" then
    f:close()
    os.execute("/etc/motd")
  else
    f:seek("set", 0)
    io.write(f:read("*a") .. "\n")
    f:close()
  end
end

boot_invoke(gpu,"fill",w,h," ")

while true do
  motd()
  local result, reason = os.execute(os.getenv("SHELL"))
  if not result then
    io.stderr:write((reason ~= nil and tostring(reason) or "unknown error") .. "\n")
    io.write("Press any key to continue.\n")
    os.sleep(0.5)
    require("event").pull("key")
  end
  require("term").clear()
end
