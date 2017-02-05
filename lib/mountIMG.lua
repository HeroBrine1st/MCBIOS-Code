--Укажете папку на другой файловой системе - не будет работать. найти прокси корневой (в которой все работает) - fs.get("/")

local filesystem = require("filesystem")
local fs = require("filesystem")
local component = require("component")
local computer = require("computer")
local img = {}



function img.mountIMG(otkyda,kyda,write)
if not type(otkyda) == "string" 		then error("Bad argument #1 (String expected, got " .. 	type(otkyda) .. ")") 	end
if not type(kyda) == "string" 			then error("Bad argument #2 (String expected, got " .. 	type(kyda) 	 .. ")")	end
if not type(write) == "boolean" 		then error("Bad argument #3 (Boolean expected, got " .. type(write)  .. ")")	end
if not filesystem.isDirectory(otkyda) 	then error("Bad argument #1 (Directory expected, got file)") 					end



	local rootFS = fs.get(otkyda)
	local proxy = {}
	proxy.convertPath = function(path) 
		local newPath
		if otkyda:sub(1,-1) == "/" then
			newPath = otkyda .. path
		else
			newPath = otkyda .. "/" .. path
		end
		return newPath
	end
	proxy.address = "VirtualFS" .. tostring(math.random(0x000000,0xFFFFFF))
	proxy.type = "filesystem"
	proxy.label = proxy.address
	proxy.spaceUsed = fs.get(otkyda).spaceUsed
	proxy.spaceTotal = fs.get(otkyda).spaceTotal 
	proxy.makeDirectory = function(dir) 
		if write then
			fs.get(otkyda).makeDirectory(proxy.convertPath(dir))
		else
			error("Permission Denied")
		end
	end
	proxy.isReadOnly = function() return not write end
	proxy.rename = function(from,to) 
		if write then
			fs.get(otkyda).rename(proxy.convertPath(from),proxy.convertPath(to))
		else
			error("Permission Denied")
		end
	end
	proxy.remove = function(chto) if write then
		fs.get(otkyda).remove(proxy.convertPath(chto))
	else
		error("Permission Denied")
	end
	 end
	proxy.setLabel = function(label) if write then proxy.label = label end end
	proxy.size = function(path) return fs.get(otkyda).size(proxy.convertPath(path)) end
	proxy.getLabel = function() return proxy.label end


	proxy.exists = function(path)
		return rootFS.exists(proxy.convertPath(path))
	end
	proxy.open = function(path,mode)
	if write then
		return rootFS.open(proxy.convertPath(path),mode)
	else
		if mode == "r" then return rootFS.open(proxy.convertPath(path),"r") else error("Permission Denied") end
	end
	end
	proxy.read = function(h, ...)
		return rootFS.read(h,...)
	end
	proxy.close = function(h)
		return rootFS.close(h)
	end
	proxy.write = function(h, ...)
		if write then
			return rootFS.write(h,...)
		else
			error("Permission Denied")
		end
	end
	proxy.seek = function(h, ...)
		return rootFS.seek(h, ...)
	end
	proxy.isDirectory = function(path)
		return rootFS.isDirectory(proxy.convertPath(path))
	end
	proxy.list = function(path)
		return rootFS.list(proxy.convertPath(path))
	end
	fs.umount(kyda)
	fs.mount(proxy,kyda)
	return proxy
end

return img
