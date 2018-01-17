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
local focusedPlayers = {}
if data then
  players = data.players
  accessChats = data.accessChats
  moders = data.moders
  token = data.token
  focusedPlayers = data.focus or {}
end
if not token then error("Not enough token key") end
data = nil
local timeout = 604800
local lastSave
local period = 600
------------------------------------------------------------------------------

local function saveData()
  local data = {}
  data.players = players
  data.moders = moders
  data.accessChats = accessChats
  data.token = token
  data.focus = focusedPlayers
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
    while not (file or res) do
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

local function eventFocusedPlayers(nickname,msg)
  if focusedPlayers[nickname] then
    local data, time = getTime()
    local text = "[" .. tostring(data) .. "] [" .. tostring(time) .. "] " .. nickname .. "> " .. msg 
    table.insert(focusedPlayers[nickname],text)
  end
end

local function addFocusPlayer(nickname)
  focusedPlayers[nickname] = focusedPlayers[nickname] or {}
end

local function encode(code)
  if code then
    code = string.gsub(code, "([^%w ])", function (c)
      return string.format("%%%02X", string.byte(c))
    end)
    code = string.gsub(code, " ", "+")
  end
  return code 
end

function uploadToPastebin(name,text,sendF)
  sendF("Uploading " .. name)
  local config = {}
  local configFile = loadfile("/etc/pastebin.conf", "t", config)
  if configFile then
    local result, reason = pcall(configFile)
    if not result then
      sendF("Failed loading config: " .. reason)
    end
  end
  config.key = config.key or "fd92bd40a84c127eeb6804b146793c97"
  local result, response = pcall(require("internet").request,
        "https://pastebin.com/api/api_post.php", 
        "api_option=paste&" ..
        "api_dev_key=" .. config.key .. "&" ..
        "api_paste_format=lua&" ..
        "api_paste_expire_date=N&" ..
        "api_paste_name=" .. encode(name) .. "&" ..
        "api_paste_code=" .. encode(text))

  if result then
    local info = ""
    for chunk in response do
      info = info .. chunk
    end
    if string.match(info, "^Bad API request, ") then
      sendF("Failed.\n")
      sendF(info)
    else
      sendF("Success.\n")
      local pasteId = string.match(info, "[^/]+$")
      sendF("pastebin.com/" .. tostring(pasteId))
    end
  else
    sendF("failed.\n")
    sendF(response)
  end
end

local function uploadReportPlayer(nickname,chatID)
  if not focusedPlayers[nickname] then TG.sendMessage(token,chatID,"No report.") end
  local sendF = function(msg) TG.sendMessage(token,chatID,msg) end
  local text = ""
  for _, value in pairs(focusedPlayers[nickname]) do
    text = text .. value .. "\n"
  end
  uploadToPastebin(nickname .. " report",text,sendF)
end

local function checkAllOnline()
   for key, _ in pairs(players) do
      local online = getOnline(key)
      local _, _, time = getTime()
      if online and players[key][1] == 0 then players[key][1] = 1 send(key .. " join the game.") eventFocusedPlayers(key,"join the game") end
      if not online and players[key][1] == 1 then players[key][1] = 0 players[key][2] = time + timeout send(key .. " left the game.") eventFocusedPlayers(key,"left the game") end
      local player, doErase = checkTimeout(key)
      if doErase then send(key .. " removed from database by timeout.") players[key] = nil end
   end
end

local tgsmsg = TG.sendMessage
TG.sendMessage = function(token,chatID,text)
  if chatID == "game" then chat.say(text) send(text) else tgsmsg(token,chatID,text) end
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
    githubFlash(chatID)
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
	elseif command[1] == "focus" then
    addFocusPlayer(command[2])
    TG.sendMessage(token,chatID,"Success")
  elseif command[1] == "loadfocus" then
    uploadReportPlayer(command[2],chatID)
  elseif command[1] == "getAST" then 
    TG.sendMessage(token,chatID,tostring(period - (computer.uptime() - lastSave)) .. " seconds remaining")
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
require("term").clear()
local function checkGamechatMsg(nick,msg)
  msg = tostring(msg)
  nick = tostring(nick)
  if not msg:sub(1,2) == "TG" then return true end
  if msg:sub(1,2) == "TG" then
    msg = msg:sub(3)
    local nickPassed = false
    for i = 1, #moders do
      if nick == moders[i] then nickPassed = true end
    end
    if not nickPassed then return true end
    send("Executing command \"" .. msg .. "\" by " .. nick)
    procCmd(msg,"game")
  else
    return true
  end
end


function autoSave()
  send("Automatic save") saveData() send("Success")
  lastSave = computer.uptime()
end

send("Bot switched on")
while true do
  if not lastSave then autoSave() end
	checkAllOnline()
	local _, _, nick, msg = event.pull(0.5,"chat_message")
  checkGamechatMsg(nick,msg)
  if computer.uptime() - lastSave > period - 1 then autoSave() end
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
