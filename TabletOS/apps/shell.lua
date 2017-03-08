local component = require("component")
local gpu = component.gpu
local w,h = gpu.getResolution()
local term = require("term")
local shell = require("shell")
local ecs = require("ECSAPI")
local printBackup = print

local function redrawBar()
	local oldB = gpu.setBackground(0xFFFFFF)
	local oldF = gpu.setForeground(0xFFFFFF-0xCCCCCC)
	gpu.fill(1,1,w,5," ")
	local str = "Material terminal"
	gpu.set(w/2-math.floor(string.len(str)/2),3,str)
	gpu.set(1,4,"Working directory: " .. require("shell").getWorkingDirectory())
	gpu.setBackground(oldB)
	gpu.setForeground(oldF)
end

local function drawInput()
	local oldPixels = ecs.rememberOldPixels(1,h-5,w,h)
	local oldB = gpu.setBackground(0xFFFFFF)
	local oldF = gpu.setForeground(0xFFFFFF-0xCCCCCC)
	gpu.fill(1,h-4,w,5," ")
	gpu.set(1,h,"Made by HeroBrine1")
	local function input()
		gpu.set(1,h-2,">")
		return ecs.inputText(2,h-2,w-1)
	end
	while true do
		local result = input()
		if input ~= nil and input ~= "" then
			ecs.drawOldPixels(oldPixels)
			gpu.setBackground(oldB)
			gpu.setForeground(oldF)
			return result 
		end
	end
end

function print(...)
	printBackup(...)
end

local function execute(command)
	local success, reason = shell.execute(command)
	if not success and not reason == "file not found" and not reason == "interrupted" then
		reason = debug.traceback(reason) .. "\n"
	end
	return success, reason
end

redrawBar()
while true do
redrawBar()
local xC, yC = term.getCursor()
if yC < 6 then term.setCursor(1,6) end
local path = shell.getWorkingDirectory()
local result = drawInput()
term.clear()
redrawBar()
term.setCursor(1,6)


local success, reason = execute(result)
if not success then
io.stderr:write(reason)
end
end
