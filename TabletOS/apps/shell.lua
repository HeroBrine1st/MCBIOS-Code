local shell = require("shell")
local term = require("term")
local ecs = require("ECSAPI")
term.clear()
local success, oldShellPixels = false, nil
while success == false do
success, oldShellPixels = pcall(ecs.rememberOldPixels,1,1,80,25)
if success == false then io.stderr:write(oldShellPixels) end
end
term.clear()
local function execute(command)
	local success, reason = shell.execute(command)
	if not success then
		reason = debug.traceback(reason)
	end
	return success, reason
end


while true do
local path = shell.getWorkingDirectory()
io.stderr:write("Root@TabletOS".. path .. "#")
local result
while true do
result = io.read()
if result ~= nil and result ~= "" then
break
else
io.stderr:write("Root@TabletOS".. path .. "#")
end
end
local success, reason = execute(result)
if not success then
io.stderr:write(reason)
end
end
