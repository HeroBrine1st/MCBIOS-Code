local component = require("component")
local gpu = require("gpu")
local unicode = require("unicode")
local AGPU = {}
local e = {}

function AGPU.drawText(x,y,color,text)
local foreground = gpu.setForeground(color)
gpu.set(x,y,text)
gpu.setForeground(foreground)
local addToE = {
	x,
	y,
	color,
	text,
}
table.insert(e,addToE)
table.sort(e)
end

function AGPU.drawCenterText(x,y,color,text)
local len = unicode.len(text)
local aX = x-len
local foreground = gpu.setForeground(color)
gpu.set(aX,y,text)
gpu.setForeground(foreground)
local addToE = {
	aX,
	y,
	color,
	text,
}
table.insert(e,addToE)
table.sort(e)
end

return AGPU
