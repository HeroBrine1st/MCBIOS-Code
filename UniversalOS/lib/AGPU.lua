local component = require("component")
local gpu = component.gpu
local unicode = require("unicode")
local AGPU = {
	elements = {}
}

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
local index = #(AGPU.elements) + 1
table.insert(AGPU.elements,addToE)
return index
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
local index = #(AGPU.elements) + 1
table.insert(AGPU.elements,addToE)
return index
end



return AGPU
