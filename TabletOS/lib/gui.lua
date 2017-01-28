local gui = {}

function gui.drawProgressBar(x,y,w,colorEmpty,colorFilled,progress,maxProgress)
colorEmpty = colorEmpty or 0x000000
colorFilled = colorFilled or 0xFFFFFF
progress = progress or 0
maxProgress = maxProgress or 100
local h = 1
local coff = w/maxProgress
local celoe, drobnoe = math.modf(coff*progress)
local progressVCordax
if drobnoe > 0.5 then progressVCordax = celoe+1 else progressVCordax = celoe end
local oldBackground = gpu.setBackground(colorEmpty)
gpu.fill(x,y,w,1," ")
gpu.setBackground(colorFilled)
gpu.fill(x,y,progressVCordax,1," ")
gpu.setBackground(oldBackground)
end
