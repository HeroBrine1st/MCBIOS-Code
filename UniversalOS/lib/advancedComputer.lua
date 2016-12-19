local computer = require("computer")
local aComputer = {}

function aComputer.shutdown()
term.clear()
print("The system will shutdown NOW")
computer.shutdown()
end

function aComputer.reboot()
term.clear()
print("The system will shutdown NOW")
computer.shutdown(true)
end

return aComputer
