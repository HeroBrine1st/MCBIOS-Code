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
      local oldcolors = boot_invoke(gpu,"getForeground")
      boot_invoke(gpu, "setForeground", color)
      boot_invoke(gpu, "set", x, y, text)
      boot_invoke(gpu, "setForeground", oldcolors)
  end

w, h = boot_invoke(gpu,"getResolution")
centerText(h/2-1,"UniversalOS",0xFFFFFF)
centerText(h/2,"Booting recovery kernel...",0xFFFFFF)


do
  _G._OSVERSION = "OpenOS 1.5"

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
--local success, reason = pcall(loadfile("/recovery/recovery.lua"))
boot_invoke(gpu,"fill",w,h," ")

do
local filesystem = require("filesystem")
local component = require("component")
local computer = require("computer")
local fs = require("filesystem")
local internet = require("internet")
local shell = require("shell")
local GitHubInstallerUrl = "https://raw.githubusercontent.com/HeroBrine1st/OpenComputers/master/UniversalOS/UOS/install.lua"
local GitHubApplicationsUrl = "https://raw.githubusercontent.com/HeroBrine1st/OpenComputers/master/UniversalOS/UOS/applications.txt"
local gpu =  component.gpu
local event = require("event")
local package = require("package")
local term = require("term")
local image = require("image")
local buffer = require("DoubleBuffering")
local w,h = gpu.getResolution()
gpu.setBackground(0x000000)
gpu.setForeground(0xFFFFFF)
gpu.fill(1,1,w,h," ")
os.sleep(1)
if not fs.exists("/recovery/recovery.pic") then
local str ="UniversalOS"
local lenght = (unicode.len(str)/2)
gpu.set(w/2-lenght,h/2-1,str)
local str ="Booting recovery"
local lenght = (unicode.len(str)/2)
gpu.set(w/2-lenght,h/2,str)
os.sleep(3)
else
local bootImage = image.load("/recovery/recovery.pic")
local pic
local i = 255
while i > 0 do
i = i - 17
pic = image.photoFilter(bootImage,0x000000,i)
buffer.image(1,1,pic)
buffer.draw()
end
end
local function internetRequest(url)
  local success, response = pcall(component.internet.request, url)
    if success then
    local responseData = ""
    while true do
      local data, responseChunk = response.read()
      if data then
        responseData = responseData .. data
      else
        if responseChunk then
         return false, responseChunk
        else
      return true, responseData
    end
    end
    end
  else
    return false, reason
  end
end
 local write = io.write
local read = io.read



local function getFromGitHub(url,filepath)
 local success, reason = internetRequest(url)
 if success then
   fs.makeDirectory(fs.path(filepath) or "")
   fs.remove(filepath)
   local file = io.open(filepath, "w")
   file:write(reason)
   file:close()
   return success, reason
 else
   io.stderr("Can't download " .. url .. "\n")
 end
end
local function dI()
_G.eventInterruptBackup = package.loaded.event.shouldInterrupt 
_G.eventSoftInterruptBackup = package.loaded.event.shouldSoftInterrupt 
package.loaded.event.shouldInterrupt = function () return false end
package.loaded.event.shouldSoftInterrupt = function () return false end
end


local function eI()
if _G.eventInterruptBackup then
package.loaded.event.shouldInterrupt = _G.eventInterruptBackup 
package.loaded.event.shouldSoftInterrupt = _G.eventSoftInterruptBackup
end
end
local w,h = gpu.getResolution()
local function firstMenu()
gpu.setBackground(0xCCCCCC)
gpu.fill(1,1,w,h," ")
gpu.setBackground(0xFFFFFF)
gpu.setForeground(0x000000)
gpu.fill(1,3,w,3," ")
gpu.set(1,3,"Reinstall system")
gpu.setBackground(0xFFFFFF)
gpu.setForeground(0x000000)
gpu.fill(1,1,w,1," ")
gpu.set(1,1,"Reboot system now")
gpu.setForeground(0xFFFFFF)
gpu.setBackground(0xCCCCCC)
gpu.set(1,2,"Repair/update system")
gpu.setForeground(0xFFFFFF)
gpu.setBackground(0xCCCCCC)
gpu.fill(1,4,w,4," ")
gpu.set(1,4,"Power off")
gpu.setForeground(0xFFFFFF)
gpu.setBackground(0xCCCCCC)
gpu.fill(1,5,w,6," ")
end

local w,h = gpu.getResolution()
local function status(msg)
end

gpu.setBackground(0xCCCCCC)
gpu.fill(1,1,w,h," ")

--status("Booting recovery")
firstMenu()

while true do
local touch = {event.pull("touch")}
if touch[4]==3 then
gpu.setBackground(0x000000)
term.clear()
dofile("/bin/install.lua")
os.sleep(1)
firstMenu()
end
if touch[4]==1 then
gpu.setBackground(0x000000)
term.clear()
eI()
computer.shutdown(true)
break
end
if touch[4]==2 then
  gpu.setBackground(0x000000)
  term.clear()
  write("Downloading file list...    ")

local success, reason = getFromGitHub("https://raw.githubusercontent.com/HeroBrine1st/OpenComputers/master/UniversalOS/UOS/applications.txt","/UOS/applications.txt")

  
  local applications
  if success == true then
dfile = "return " .. string.gsub(reason,"\n","")
write("Success\n\n")
else
error("Error. Reason: " .. reason)
end

  local file = io.open("/UOS/apps.lua","w") 
  file:write(dfile)
  file:close()
  applications = dofile("/UOS/apps.lua")
  local result = "y"
  io.write("\n")
    if not result or result == "" or result:sub(1, 1):lower() == "y" then
      for i = 1, #applications do
        print("Check " .. applications[i].path)
        local size = fs.size(applications[i].path)
          if fs.exists(applications[i].path) == true then
            local file = io.open(applications[i].path,"r")
            local text = file:read(size+1)
            file:close()
            local success, textOriginal = getFromGitHub(applications[i].url,"/tmp/recovery.tmp")
            if text == textOriginal then
              print(applications[i].path .. " true")
            else
              write("Downloading " .. applications[i].path .. "    ")
              local success, reason = getFromGitHub(applications[i].url,applications[i].path)
              if success == true then
        io.write("Success\n")
        end
        if success == false then
        io.stderr("error. Reason: " .. reason)
        end
            end
          else
            write("Downloading " .. applications[i].path .. "    ")
              local success, reason =  getFromGitHub(applications[i].url,applications[i].path)
              if success == true then
io.write("Success\n")
end
if success == false then
io.stderr("Error. Reason: " .. reason)
end
          end
        end
      end
term.clear()
firstMenu()
end
if touch[4]==4 then
gpu.setBackground(0x000000)
term.clear()
eI()
computer.shutdown()
end
end

end



  require("term").clear()
  os.sleep(0.1) -- Allow init processing.
runlevel = 1

end
