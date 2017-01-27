local function loadFile(file)
local filesystem = component.proxy(computer.getBootAddress())
local handle, reason = filesystem.open(file,"r")
if not handle then error(reason) end
local readed = ""
repeat
	local data = filesystem.read(handle,math.huge)
	readed = readed .. data
until not data
return load(readed)
end

local success, reason = pcall(loadFile("/boot.lua"))
if not success then error(reason) end
