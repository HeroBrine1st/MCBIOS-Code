local event = require("event")
local fs = require("filesystem")
local component = require("component")
local gpu = component.gpu
local ecs = require("ECSAPI")
local term = require("term")
local unicode = require("unicode")
local zygote = require("zygote")
local Math = math
local shell =  require("shell")
local oldPixelsM = {}
local w,h = gpu.getResolution()

local fileManagerPixels = ecs.rememberOldPixels(1,1,80,25)
gpu.setBackground(0x610B5E)
gpu.setForeground(0xFFFFFF)
gpu.set(1,1,languagePackages[language].fileManager)
local form = zygote.addForm()
form.left=1
form.top=2
form.W=80
form.H=23
form.color=0xCCCCCC

local function setActiveForm()
form:setActive()
end
local function stopForm(view)
zygote.stop(form)
ecs.drawOldPixels(fileManagerPixels)
end
local currentPath = "/"
local oldFormPixels
	





local list = form:addList(1,2,function(view)
local value = view.items[view.index]
if fs.isDirectory(value) then
	oldPath = currentPath
	currentPath = value
	view:clear()
	view:insert("/","/")
	view:insert("..",oldPath)
	for name in fs.list(currentPath) do
view:insert(name,currentPath .. name)
end
elseif fs.exists(value) then
oldFormPixels = ecs.rememberOldPixels(1,1,80,25)
local windowForm = zygote.addForm()
windowForm.left = 35
windowForm.top = 12-2
windowForm.W = 10
windowForm.H = 4

windowButton1 = windowForm:addButton(1,1,"Edit",function()
shell.execute("edit " .. value)
ecs.drawOldPixels(oldFormPixels)
setActiveForm()
end)
windowButton2 = windowForm:addButton(1,2,"Execute",function()
term.clear()
shell.execute(value)
ecs.drawOldPixels(oldFormPixels)
setActiveForm()
end)
windowButton3 = windowForm:addButton(1,3,"Remove",function()
shell.execute("rm " .. value)
ecs.drawOldPixels(oldFormPixels)
setActiveForm()
end)
local function stopFormS()
zygote.stop(windowForm)
end
windowButton4 = windowForm:addButton(1,4,"Exit",function()
stopFormS()
ecs.drawOldPixels(oldFormPixels)
setActiveForm()
end)
windowButton1.W=10
windowButton2.W=10
windowButton3.W=10
windowButton4.W=10

zygote.run(windowForm)

setActiveForm()
end
end)




list.W = 80
list.H = 22
list.color = 0xCCCCCC
list.fontColor = (0xFFFFFF - 0xCCCCCC)
list.border = 0
local function updateFileList()
local listBackup = list
list:clear()
list:insert("/","/")
list:insert("..",listBackup.items[2])
for name in fs.list(currentPath) do
list:insert(name,currentPath .. name)
end
listBackup = nil
end
local newFolder = form:addButton(1,1,languagePackages[language].newFolder,function()
		oldFormPixels = ecs.rememberOldPixels(1,1,80,25)
		local windowForm = zygote.addForm()
		windowForm.left = 30
		windowForm.top = 25/2-2
		windowForm.W = 20
		windowForm.H = 4

		local editor = windowForm:addEdit(1,1,function(view)
			local value = view.text
			if value then
				local newFolder = currentPath .. value
				fs.makeDirectory(newFolder)
				ecs.drawOldPixels(oldFormPixels)
				setActiveForm()
				updateFileList()
			end
		end)
		zygote.run(windowForm)
end)
newFolder.W = 20


	local newFile = form:addButton(21,1,languagePackages[language].newFile,function()
		oldFormPixels = ecs.rememberOldPixels(1,1,80,25)
		local windowForm = zygote.addForm()
		windowForm.left = 30
		windowForm.top = 25/2-2
		windowForm.W = 20
		windowForm.H = 4

		local editor = windowForm:addEdit(1,1,function(view)
			local value = view.text
			if value then
				local newFile = currentPath .. value
				local f = io.open(newFile,"w")
				if f then
					f:write("")
					f:close()
				end
				ecs.drawOldPixels(oldFormPixels)
				setActiveForm()
				updateFileList()
			end
		end)
		zygote.run(windowForm)
	end)
newFile.W = 20

local updateButton = form:addButton(41,1,languagePackages[language].updateFileList,updateFileList)
updateButton.W = 20
updateFileList()
local function eventListener(_,_,x,y,button,_)
	if button == 0 and (x == 40 or x == 35) and y == 25 then
		pcall(stopForm)
	end
end
form:addEvent("touch",eventListener)
zygote.run(form)
