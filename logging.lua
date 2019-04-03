
-- Server logging script by Devieth.
-- For SAPP

--[[ Save format:
ProfilePlath >
	logs >
		date(mm-dd-yy) >
			chat.log
			commands.log
			join.log
]]

join_logging = true
chat_logging = true
command_logging = true

api_version = "1.10.0.0"
ce, client_info_size = 0x40, 0xEC

function OnScriptLoad()
	save_location = read_string(read_dword(sig_scan("68??????008D54245468") + 0x1)).."\\logs\\"
	network_struct = read_dword(sig_scan("F3ABA1????????BA????????C740??????????E8????????668B0D") + 3)
	if halo_type == "PC" then ce, client_info_size = 0x0, 0x60 end
	if join_logging then register_callback(cb['EVENT_JOIN'], "OnPlayerJoin") end
	if chat_logging then register_callback(cb['EVENT_CHAT'], "OnPlayerChat") end
	if command_logging then register_callback(cb['EVENT_COMMAND'], "OnCommand") end
end

function OnCommand(PlayerIndex, Command, Enviroment, Password)
	if tonumber(PlayerIndex) ~= 0 then
		local Command = string.gsub(Command, [["]], "")
		local date = os.date("%m-%d-%y")
		local time = os.date("%X")
		local name, ip, hash = get_player_data(PlayerIndex)
		local lvl = get_var(PlayerIndex, "$lvl")
		if tonumber(Enviroment) ~= 0 then
			local line = nil
			if tonumber(Enviroment) == 2 then
				line = string.format("%s	(CHAT)	Level: %s	Name: %s	Command: %s", time, lvl, name, Command)
			else
				line = string.format("%s	(RCON)	Level: %s	Name: %s	Command: %s", time, lvl, name, Command)
			end
			file_write("commands.log", date, line)
		end
	end
end

function OnPlayerJoin(PlayerIndex)
	local date = os.date("%m-%d-%y")
	local time = os.date("%X")
	local name, ip, hash = get_player_data(PlayerIndex)
	local line = string.format("%s	Name: %s	IP: %s	Hash: %s", time, name, ip, hash)
	file_write("join.log", date, line)
end

function OnPlayerChat(PlayerIndex, Message)
	local date = os.date("%m-%d-%y")
	local time = os.date("%X")
	local name, ip, hash = get_player_data(PlayerIndex)
	local line = string.format("%s	Name: %s	Message: %s", time, name, Message)
	file_write("chat.log", date, line)
end

function get_player_data(PlayerIndex)
	local name = get_var(PlayerIndex, "$name")
	local ip = get_ip(PlayerIndex)
	local hash = get_var(PlayerIndex, "$hash")
	return name, ip, hash
end

-- Use this function to grab the connection IP.
-- Do this because get_var(PlayerIndex, "$ip") gets the last "known" ip that held that PlayerIndex.
function get_ip(PlayerIndex)
	local m_connection_info = read_dword(read_dword(read_dword(get_client_machine_info(PlayerIndex))))
	local ip = {}
	local port = read_word(m_connection_info + 0x4)
	for i = 0,3 do
		table.insert(ip, i+1, read_byte(m_connection_info + i))
	end
	return table.concat(ip, "."), port
end

function get_client_machine_info(PlayerIndex)
	if player_present(PlayerIndex) then
		return network_struct + 0x3B8 + ce + to_real_index(PlayerIndex) * client_info_size
	else
		return network_struct + 0x3B8 + ce + (tonumber(PlayerIndex) - 1) * client_info_size
	end
end

function file_write(Filename, SubPath, String, Mode)
	Mode = Mode or "a+"
	-- Make sure the save directory exits and return the path, if not create it and return the path.
	local file_path = directory_exists(save_location..SubPath.."\\")
	if file_path ~= false then
		local file = io.open(file_path .. Filename, Mode)
		if file then
			file:write(String.."\n")
			file:close()
		end
	end
end

function directory_exists(Path)
	if type(Path) ~= "string" then return false end
	local response = os.execute("cd " .. Path)
	if response == 0 then
		return Path
	end
	os.execute('mkdir "'..Path..'"')
	print('Log Directory Created: "'..Path..'"')
	return Path
end

function tokenizestring(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end
