local function loadFile(file)
local filesystem = component.proxy(computer.getBootAddress())
local handle, reason = filesystem.open(file,"r")
if not handle then error(reason) end

	local data, reason = filesystem.read(handle,40000000)
	if not data and reason then error(reason) end

return load(data)
end

local success, reason = pcall(loadFile("/boot.lua"))
if not success then error(reason) end
