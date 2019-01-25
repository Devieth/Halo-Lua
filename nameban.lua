
-- Name Banning by Devieth
-- Script for SAPP

api_version = "1.10.0.0"
filename = "bans.data"

function OnScriptLoad()
	register_callback(cb['EVENT_PREJOIN'], "PreJoin")
	register_callback(cb['EVENT_COMMAND'], "Command")
	network_struct = read_dword(sig_scan("F3ABA1????????BA????????C740??????????E8????????668B0D") + 3)
	if halo_type == "PC" then ce, client_info_size = 0x0,0x60 else ce, client_info_size = 0x40, 0xEC end
end

function OnScriptUnload()
end

function Command(PlayerIndex, Command, Enviroment, Password)
	local respond = true
	if isadmin(PlayerIndex) or Enviroment == 0 then
		local Command = string.gsub(Command, [["]], "")
		local t = tokenizestring(Command, " ")
		if t[1] == "ban" then
			respond = false
			if t[2] ~= nil then
				if tonumber(t[2]) ~= nil then
					if player_present(t[2]) then
						local name, ip = get_var(t[2], "$name"), get_ip(t[2])
						write_ban(name..":"..ip.."\n", "a")
						xprint(PlayerIndex, get_var(t[2], "$name").." has been banned!")
						if t[3] ~= nil then
							local reason = assemble(t, 2, " ")
							say_all(name .. " has been banned from the server! Reason: '"..reason.."' 1")
							execute_command("sv_ban "..tonumber(t[2]).." 1s")
						else
							execute_command("sv_ban "..tonumber(t[2]).." 1s")
						end
						update_ban_header()
					else
						xprint(PlayerIndex, "Error: Player is not in the server.")
					end
				end
			else
				xprint(PlayerIndex, "Error: Please use the players number.")
			end
		elseif t[1] == "unban" then
			respond = false
			if tonumber(t[2]) ~= nil then
				read_bans()
				local removed = false
				for i = 1,#lines do
					if i == tonumber(t[2]) then
						xprint(PlayerIndex, lines[i] .. " has been unbanned!")
						table.remove(lines, i)
						removed = true
						break
					end
				end
				if removed then
					rebuild_bans()
				else
					xprint(PlayerIndex, "Error: Failed to unban player or the ban may not exist.")
				end
			else
				xprint(PlayerIndex, "Error: Please use the ban id.")
			end
		elseif t[1] == "bans" then
			respond = false
			list_bans(PlayerIndex)
		end
	end
	return respond
end

function PreJoin(PlayerIndex)
	local name = read_widestring((network_struct + 0x1AA + ce + to_real_index(PlayerIndex) * 0x20), 12)
	local ip = get_ip(PlayerIndex)
	read_bans(PlayerIndex, name, ip)
end

function get_ip(PlayerIndex)
	local m_connection = read_dword(read_dword(read_dword(get_client_machine_info(PlayerIndex))))
	local m_1 = read_byte(m_connection)
	local m_2 = read_byte(m_connection + 0x1)
	local m_3 = read_byte(m_connection + 0x2)
	local m_4 = read_byte(m_connection + 0x3)
	return m_1.."."..m_2.."."..m_3.."."..m_4
end

function isadmin(PlayerIndex)
	if player_present(PlayerIndex) then
		local lvl = get_var(PlayerIndex, "$lvl")
		if lvl ~= "-1" then
			return true
		end
	end
	return false
end

function read_bans(PlayerIndex, name, ip)
	local file = io.open(filename, "rb")
	if file then
		lines = {}
		for line in io.lines(filename) do
			lines[#lines + 1] = line
			if name ~= nil then
				local t = tokenizestring(line, ":")
				if t[1] == name or t[2] == get_ip(PlayerIndex) then
					execute_command("sv_ban "..PlayerIndex.." 1s")
					update_ban_header()
					break
				end
			end
		end
		file:close()
	end
end

function list_bans(PlayerIndex)
	read_bans()
	if lines then
		if #lines > 0 then
			for k,v in pairs(lines) do
				if k == 1 then
					xprint(PlayerIndex, "Index|tName:Ip")
				end
				xprint(PlayerIndex,'[' .. k .. ']|t'.. v)
			end
		else
			xprint(PlayerIndex, "Error: There are no bans.")
		end
	else
		xprint(PlayerIndex, "Error: There are no bans.")
	end
end

function rebuild_bans()
	if #lines > 0 then
		for i = 1,#lines do
			if i == 1 then
				write_ban(lines[i].."\n", "w+")
			else
				write_ban(lines[i].."\n", "a")
			end
		end
	else
		write_ban("", "w+")
	end
	read_bans()
end

function update_ban_header()
	if halo_type == "CE" then
		local banlist_size = read_dword(0x5C5280)
		execute_command("sv_unban ".. banlist_size - 1)
	end
end

function write_ban(value, mode)
	local file = io.open(filename, mode)
	if file then
		file:write(value)
		file:close()
	end
end

function xprint(PlayerIndex, Message)
	if tonumber(PlayerIndex) ~= 0 then
		rprint(PlayerIndex, Message)
	else
		local Message = string.gsub(Message, "|t", "	")
		cprint(Message, 10)
	end
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

function assemble(t, start, spacer)
	local words = {}
	for i = 1,#t do
		if i > start then
			if i == #t then
				words[i-start] = t[i]
			else
				words[i-start] = t[i] .. spacer
			end
		end
	end
	return table.concat(words)
end

function read_widestring(address, length)
    local count = 0
    local byte_table = {}
    for i = 1,length do -- Reads the string.
        if read_byte(address + count) ~= 0 then
            byte_table[i] = string.char(read_byte(address + count))
        end
        count = count + 2
    end
    return table.concat(byte_table)
end

function get_client_machine_info(PlayerIndex)
	if player_present(PlayerIndex) then
		return network_struct + 0x3B8 + ce + to_real_index(PlayerIndex) * client_info_size
	else
		return network_struct + 0x3B8 + ce + (tonumber(PlayerIndex) - 1) * client_info_size
	end
end
