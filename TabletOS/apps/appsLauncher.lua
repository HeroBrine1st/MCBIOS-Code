local pm = require("pm")
local shell = require("shell")
local zygote = require("zygote")
local fs = require("filesystem")
local event = require("event")
local ecs = require("ECSAPI")
local form = zegote.addForm()
form.left = 1
form.top = 2
form.W = 80
form.H = 23
local list = form:addList(1,1,function(view)
	local value = view.items[view.index]
	local windowForm = zygote.addForm()
	windowForm.left = 30
	windowForm.top = 12-2
	windowForm.W = 20
	windowForm.H = 3

	windowButton1 = windowForm:addButton(1,1,"Execute",function()
		OSAPI.ignoreListeners()
		local success, reason = shell.execute(value)
		pcall(event.cancel,_G.timerID)
		pcall(event.cancel,timerID)
		if not success then ecs.error(reason) end
		OSAPI.init()
		form:setActive()
	end)
		windowButton2 = windowForm:addButton(1,2,"Uninstall",function()
		pm.uninstallApp(fs.name(value))
		form:setActive()
	end)
	windowButton3 = windowForm:addButton(1,2,"Exit",function()
		zygote.stop(windowForm)
		form:setActive()
	end)
	zygote.run(windowForm)
end)
for _, dir in pairs(pm.listOfApps(true)) do
	list:insert(fs.name(dir),dir)
end
for _, dir in pairs(pm.listOfApps(false)) do
	list:insert(fs.name(dir),dir)
end
list.W = 80
list.H = 23
local function eventListener(_,_,x,y,button,_)
	if button == 0 and (x == 40 or x == 35) and y == 25 then
		local success, reason = pcall(zygote.stop,form)
		if not success then
			if reason then
				ecs.error("Unable to exit program:" .. reason)
			end
		end
	end
end

local event = form:addEvent("touch",eventListener)
OSAPI.init()
zygote.run(form)
