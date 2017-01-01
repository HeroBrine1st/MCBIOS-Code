local component = require("component")
local gpu = component.gpu

local hbfirst = {}


function hbfirst.setPixel(x,y,color)
local oldColor = gpu.setBackground(color)
gpu.set(x,y," ")
gpu.setBackground(oldColor)
end

function hbfirst.drawButton(x,y,w,h,text,buttonColor,textColor)
local oldBackground = gpu.setBackground(buttonColor)
local oldForeground = gpu.setForeground(textColor)
gpu.fill(x,y,w,h," ")
local x2 = w/2-string.len(text)
local y2 = h/2
local tx = x+x2
local ty = x+y2-1
gpu.set(tx,ty,text)
gpu.setBackground(oldBackground)
gpu.setForeground(oldForeground)
os.sleep(0.1)
end

function hbfirst.clickedAtArea(x,y,x2,y2,touchX,touchY)
if (touchX >= x) and (touchX <= x2) and (touchY >= y) and (touchY <= y2) then 
return true 
end 
return false
end

local function hbfirst.waitForClick(x,y,x2,y2)
	local event = require("event")
	while true do
		local touch = {event.pull("touch")}
		local clicked = hbfirst.clickedAtArea(x,y,x2,y2,touch[3],touch[4])
		if clicked then
			break
		end
	end
end




return hbfirst
