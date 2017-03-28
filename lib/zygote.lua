local zygote = {}
if not coroutine then coroutine = require("coroutine") end




function zygote.loadProgram(string)
	if not type(string) == "string" then error("Bad argument 1 (String expected, got " .. type(string) .. ").") end
	local program = {}
	program.env = _ENV
	local f = load(string,"=" .. tostring(USERID),"t",program.env)
	local success, voids = pcall(f)
	if not success then error(voids) end
	program.mainThread = coroutine.create(voids.main)
	if voids.destroy then
		program.destroyThread = coroutine.create(voids.destroy)
	end
	return program
end

function zygote.runProgram(program)
	if not type(program) == "table" then error("Bad argument 1 (Table expected, got " .. type(string) .. ").") end
	local success, reason = coroutine.resume(program.mainThread)
	if not success then error(reason) end
	local co = coroutine.create(function()
		while true do
			local status = coroutine.status(program.mainThread)
			if status == "dead" and program.destroyThread then coroutine.resume(program.destroyThread) end
		end
	end)
	assert(coroutine.resume(co))
end

return zygote
