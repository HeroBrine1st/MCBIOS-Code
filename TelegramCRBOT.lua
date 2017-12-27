local TG = require("Telegram")
local computer = require("computer")
local component = require("component")
local event = require("event")
local serial = require("serialization")
local chat = component.chat_box
local fs = require("filesystem")
local SD = require("SaveData")
local internet = component.internet
------------------------------------------------------------------------------

local token
local t_correction = 10787
local players = {}
local accessChats = {-275279978}
local moders = {}
local data = SD.readData("TGCR")
if data then
  players = data.players
  accessChats = data.accessChats
  moders = data.moders
  token = data.token
end
if not token then error("Not enough token key") end
data = nil
local timeout = 604800

------------------------------------------------------------------------------

local function saveData()
  local data = {}
  data.players = players
  data.moders = moders
  data.accessChats = accessChats
  data.token = token
  SD.saveData("TGCR",data)
end

local function split(source, delimiters)
  local elements = {}
  local pattern = '([^'..delimiters..']+)'
  string.gsub(source, pattern, function(value) elements[#elements + 1] = value;  end);
  return elements
end


local function getTime()
    local file, res
    local uptime = computer.uptime()
    while not file and not (computer.uptime() > uptime + 5) do
      file, res = io.open('/UNIX.tmp', 'w')
    end
    if not file then error("Impossible open file /UNIX.tmp: " .. tostring(res)) end
    file:write('')
    file:close()
    local lastmod = tonumber(string.sub(fs.lastModified('UNIX.tmp'), 1, -4)) + t_correction
    local data = os.date('%x', lastmod)
    local time = os.date('%X', lastmod)
    return data, time, lastmod
end

local function checkTimeout(nick)
  local doErase = false
  local player = players[nick]
  local _,_, time = getTime()
  if not player[2] or player[2] == 0 then player[2] = time + timeout end
  local timerem = player[2] - time
  if timerem < 1 then doErase = true end
  return player, doErase, timerem
end

local function getOnline(nickname)
   local online, reason = computer.addUser(nickname)
   computer.removeUser(nickname)
   return online
end

local function filter(nick)
   return getOnline(nick)
end

local function send(txt)
    for i = 1, #accessChats do
      TG.sendMessage(token,accessChats[i],txt)
    end
end

local function flash(data,chatID)
  TG.sendMessage(token,chatID,"Checking code")
  local success, reason = load(data)
  if data == "" or not data then success = false reason = "flash data is empty" end
  if not success then 
    TG.sendMessage(token,chatID,"Flash aborted. Reason: " .. tostring(reason)) 
  else
    TG.sendMessage(token,chatID,"Code right. Flashing..")
    fs.remove("/autorun2.lua")
    local f = io.open("/autorun2.lua","w")
    f:write(data)
    f:close()
    TG.sendMessage(token,chatID,"Flash success. Enter /reboot for install changes.")
  end
end


local function internetRequest(url)
  local success, response = pcall(component.internet.request, url)
  if success then
    local responseData = ""
    while true do
      local data, responseChunk = response.read()
      if data then
        responseData = responseData .. data
      else
        if responseChunk then
          return false, responseChunk
        else
          return true, responseData
        end
      end
    end
  else
    return false, response
  end
end

local function githubFlash(chatID)
  saveData()
  TG.getUpdates(token)
  local url = "https://raw.githubusercontent.com/HeroBrine1st/OpenComputers/master/TelegramCRBOT.lua"
  TG.sendMessage(token,chatID,"Flashing from github..")
  TG.sendMessage(token,chatID,"Downloading code from " .. url)
  local success, reason = internetRequest(url)
  if not success then TG.sendMessage(token,chatID,"Downloading failure: " .. reason) return end
  TG.sendMessage(token,chatID,"Flash process started")
  flash(reason,chatID)
end

local function checkAllOnline()
   for key, _ in pairs(players) do
      local online = getOnline(key)
      local _, _, time = getTime()
      if online and players[key][1] == 0 then players[key][1] = 1 send(key .. " join the game.") end
      if not online and players[key][1] == 1 then players[key][1] = 0 players[key][2] = time + timeout send(key .. " left the game.") end
      local player, doErase = checkTimeout(key)
      if doErase then send(key .. " removed from database by timeout.") players[key] = nil end
   end
end


chat.setName("HB1TelegramChatReaderBOT")
local function procCmd(command,chatID)
  local commandOrig = command
	local command = split(command," ")
  local g = string.find(command[1],"@")
  command[1] = command[1]:sub(1,(g or command[1]:len() + 1) - 1)
	if command[1] == "reboot" then
		TG.sendMessage(token,chatID,"Saving database..")
		saveData()
    TG.sendMessage(token,chatID,"Done. Rebooting...")
    TG.getUpdates(token,{offset = TG.lastUpdate})
		computer.shutdown(true)
	elseif command[1] == "say" then
    local str = ""
    for i = 2, #command do
        str = str .. command[i] .. " "
    end
		chat.say(str)
	elseif command[1] == "save" then
		TG.sendMessage(token,chatID,"Saving database...")
		saveData()
    TG.sendMessage(token,chatID,"Done.")
	elseif command[1] == "online" then
		if command[2] and not command[2] == "all" then
			local online = getOnline(command[2])
      TG.sendMessage(token,chatID,online and "Player " .. command[2] .. " online" or "Player " .. command[2] .. " offline")
		else
      local i = 0
      local activeI = 0
      for key, _ in pairs(players) do i = i + 1 activeI = activeI + (getOnline(key) and 1 or 0) end
      local str = ""
      str = str .. "List of players (" .. tostring(activeI) .. "/" .. tostring(i) .. "):\n"
      for key, value in pairs(players) do
        local online = value[1]
        local _, _, timerem = checkTimeout(key)
        if online == 1 then 
          str = str .. "Player " .. key .. " online.\n"
        elseif command[2] == "all" then 
          str = str .. "Player " .. key .. " offline. " .. "00/00/" .. tostring(os.date('%d', timerem)) .. " " .. tostring(os.date('%H', timerem)) .. ":" .. tostring(os.date('%M', timerem)) .. ":" .. tostring(os.date('%S', timerem)) .. " remaining to delete by timeout.\n"
        end
      end
      if str:len() < 4096 then
          TG.sendMessage(token,chatID,str)
      else
          for i = 1, math.ceil(#str/4096) do
              TG.sendMessage(token,chatID,str:sub(((i-1)*4096)+1,i*4096))
          end
      end
    end
  elseif command[1] == "flash" then
    if command[2] == "github" then githubFlash(chatID) else flash(commandOrig:sub(6),chatID) end
  elseif command[1] == "modonline" then
      local i = 0
      local activeI = 0
      for j = 1, #moders do i = i + 1 activeI = activeI + (getOnline(moders[i]) and 1 or 0) end
      local str = ""
      str = str .. "List of players (" .. tostring(activeI) .. "/" .. tostring(i) .. "):\n"
      for j = 1, #moders do
          key = moders[j]
          local online = getOnline(key)
          if online then
            str = str .. "Player " .. key .. " online\n"
          elseif command[2] == "all" then
            str = str .. (online and "Player " .. key .. " online" or "Player " .. key .. " offline") .. "\n"
          end
      end
      TG.sendMessage(token,chatID,str)
	else
		TG.sendMessage(token,chatID,"Missing command.")
  end
end

local function checkChat(chatID)
	for i = 1, #accessChats do
		if accessChats[i] == chatID then return true end
	end
	return false
end


send("Bot switched on")
while true do
	checkAllOnline()
	local _, _, nick, msg = event.pull(0.5,"chat_message")
	if nick and msg and filter(nick) then
		players[nick] = {}
    players[nick][1] = 1
		local _, time, timeunix = getTime()
    players[nick][2] = timeunix + timeout
		send("[" .. time .. "] " .. nick .. ": " .. msg)
	end
	local messages = TG.receiveMessages(token)
	for i = 1, #messages do
		local message = messages[i]
		local text = message.text
		local chat_id = message.chat_id
		if checkChat(chat_id) and text then
			if text:sub(1,1) == "/" then 
				print("Access allowed. Chat: " .. tostring(chat_id))
				procCmd(text:sub(2),chat_id) 
			else
				print("Access allowed. Chat: " .. tostring(chat_id))
				procCmd("say" .. " " .. text)
			end
		elseif text then
			print("Access denied. Chat: " .. tostring(chat_id))
			TG.sendMessage(token,chat_id,"Access denied. This chat id: " .. tostring(chat_id))
		end
	end
end
