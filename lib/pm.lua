local fs = require("filesystem")
local serialization = require("serialization")
local packageManager = {}
packageManager.systemAppsPath = "/apps/"
packageManager.userAppsPath = "/data/apps/"
fs.makeDirectory(packageManager.userAppsPath)
fs.makeDirectory(packageManager.systemAppsPath)

function packageManager.installApp(file,name)
	local appPath = fs.concat(packageManager.userAppsPath,name)
	fs.remove(appPath)
	fs.copy(file,appPath)
	return appPath
end

function packageManager.uninstallApp(name)
	local appPath = fs.concat(packageManager.userAppsPath,name)
	assert(fs.remove(appPath))
end

function packageManager.listOfApps(system)
	local appsDir = system and packageManager.systemAppsPath or packageManager.userAppsPath
	local list = {}
	for file in fs.list(appsDir) do 
		if not fs.isDirectory(fs.concat(appsDir,file)) then
			table.insert(list,fs.concat(appsDir,file))
		end
	end
	return list
end

return packageManager
