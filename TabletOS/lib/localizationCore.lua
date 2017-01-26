local core = {}

core.languagePackages = {
	en={
	settings="Settings",
	shutdown="Shutdown",
	reboot="Reboot",
	language="Language",
	selLanguage="Select language",
	monitorOnline="Monitor",
	enterNickname="Enter nickname:",
	logout="Logout",
	shutdownI="Shutting down",
	newFolder="New folder",
	newFile="New file",
	updateFileList="Update files",
	fileManager="File Manager",
	power="Sleep",
	},
	ru={
	settings="Настройки",
	shutdown="Выключить",
	reboot="Перезагрузить",
	language="Язык",
	selLanguage="Выберите язык",
	monitorOnline="Монитор",
	enterNickname="Введите никнейм игрока:",
	logout="Завершение сеанса",
	shutdownI="Завершение работы",
	newFolder="Новая папка",
	newFile="Новый файл",
	updateFileList="Обновить",
	fileManager="Файлы",
	power="Сон"
	}
}

function core.getLanguagePackages( ... )
	local language
	local f, r = io.open("/.tabletos","r")
	if f then
		language = f:read(fs.size("/.tabletos")+1)
		f:close()
		return core.languagePackages[language]
	else
		local f = io.open("/.tabletos","w")
		f:write("en")
		f:close()
		local language
		do
			local f, r = io.open("/.tabletos","r")
			if f then
				language = f:read(fs.size("/.tabletos")+1)
				f:close()
				return core.languagePackages[language]
			end
		end
	end
end

