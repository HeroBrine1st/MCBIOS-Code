local success, reason = pcall(loadfile("/init.d/init.OS.lua"))
if not success then
	os.error(reason)
end
