local component = require("component")
local fs = require("filesystem")
local internet = require("internet")
local shell = require("shell")
local text = require("text")

if not component.isAvailable("internet") then
  io.stderr:write("This program requires an internet card to run.")
  return
end

local args, options = shell.parse(...)
options.q = options.q or options.Q

if #args < 1 then
  io.write("Usage: wget [-fq] <url> [<filename>]\n")
  io.write(" -f: Force overwriting existing files.\n")
  io.write(" -q: Quiet mode - no status messages.\n")
  io.write(" -Q: Superquiet mode - no error messages.")
  return
end

local url = text.trim(args[1])
local filename = args[2]
if not filename then
  filename = url
  local index = string.find(filename, "/[^/]*$")
  if index then
    filename = string.sub(filename, index + 1)
  end
  index = string.find(filename, "?", 1, true)
  if index then
    filename = string.sub(filename, 1, index - 1)
  end
end
filename = text.trim(filename)
if filename == "" then
  if not options.Q then
    io.stderr:write("could not infer filename, please specify one")
  end
  return nil, "missing target filename" -- for programs using wget as a function
end
filename = shell.resolve(filename)

local preexisted
if fs.exists(filename) then
  preexisted = true
  if not options.f then
    if not options.Q then
      io.stderr:write("file already exists")
    end
    return nil, "file already exists" -- for programs using wget as a function
  end
end

local f, reason = io.open(filename, "a")
if not f then
  if not options.Q then
    io.stderr:write("failed opening file for writing: " .. reason)
  end
  return nil, "failed opening file for writing: " .. reason -- for programs using wget as a function
end
f:close()
f = nil

if not options.q then
  io.write("Downloading... ")
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



local function getFromUrl(url,filepath)
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

local success, reason = getFromUrl(url,filename)
if not success then
io.stderr:write(reason)
return
else
io.write("Success\n")
end

return success, reason -- for programs using wget as a function
