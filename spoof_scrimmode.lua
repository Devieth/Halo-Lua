-- FUCK SCRIM_MODE by Devieth
-- For SAPP

api_version = "1.10.0.0"

scrim_mode = "ON"
no_lead = "ON"

function OnScriptLoad()
	register_callback(cb['EVENT_CHAT'], "OnPlayerChat")
	register_callback(cb['EVENT_COMMAND'], "OnEventCommand")
end

function OnPlayerChat(PlayerIndex, Message)
	local allowed = true
	if Message ~= nil then
		local t = tokenizestring(string.lower(Message), " ")
		if t[1] == "\\info" or t[1] == "/info" then
			command_info(PlayerIndex)
			allowed = false
		elseif t[1] == "\\scrim_mode" or t[1] == "/scrim_mode" then
			command_scrim_mode(PlayerIndex, Message, 2)
			allowed = false
		end
	end
	return allowed
end

function OnEventCommand(PlayerIndex, Command, Enviroment, Password)
	local allowed = true
	local t = tokenizestring(string.lower(string.gsub(Command, '"', "")), " ")
	if get_var(PlayerIndex, "$lvl") ~= "-1" or tonumber(Enviroment) == 0 then
		if t[1] == "scrim_mode" then
			command_scrim_mode(PlayerIndex, string.lower(string.gsub(Command, '"', "")), Enviroment)
			allowed = false
		elseif t[1] == "no_lead" then
			if tostring(t[2]) == "1" or tostring(t[2]) == "true" then
				no_lead = "ON"
			else
				no_lead = "OFF"
			end
		end
	end
	return allowed
end

function command_info(User)
	local sv_name = string.gsub(get_var(1, "$svname"), '', "")
	local ss, mm, hh = time_stamp(game_time())
	local timeleft = tonumber(mm).." minutes "..tonumber(ss).." seconds"
	local players = (get_var(1, "$pn").."/"..read_byte(0x6C7B45))
	say(User, "SAPP Version 10.2.1 CE")
	say(User, "Server Name: "..sv_name)
	say(User, string.format("Map: %s | GameType: %s", get_var(1, "$map"), get_var(1, "$mode")))
	say(User, string.format("Time Left: %s | Players %s", timeleft, players))
	say(User, string.format("Scrim Mode: %s | NoLead: %s | Anticheat: OFF", scrim_mode, no_lead))
end

function command_scrim_mode(PlayerIndex, Command, Enviroment)
	local t = tokenizestring(string.lower(Command), " ")
	if get_var(PlayerIndex, "$lvl") ~= "-1" then
		if t[2] ~= nil then
			if tonumber(t[2]) == 1 then
				say_all("The admin has ENABLED the Scrim Mode!")
				scrim_mode = "ON"
			else
				say_all("The admin has DISABLED the Scrim Mode!")
				scrim_mode = "OFF"
			end
		else
			if scrim_mode == "ON" then
				xprint(PlayerIndex, "Scrim Mode: enabled", Enviroment)
			else
				xprint(PlayerIndex, "Scrim Mode: disabled", Enviroment)
			end
		end
	else
		xprint(PlayerIndex, "You do not have the rights to execute this command!", Enviroment)
	end
end

function game_time()
	local gametype_base = read_dword(read_dword(sig_scan("A1????????8B480C894D00") + 0x1))
	local reset_tick = read_dword(read_dword(sig_scan("8B510C6A018915????????E8????????83C404") + 7))
	local time_passed = (read_dword(gametype_base + 0xC) - reset_tick) / 30
	local time_limit = read_dword(0x5F54F0) / 30
	local time_left = time_limit - tonumber(time_passed)
	return time_left --, time_passed, reset_tick
end

function time_stamp(Seconds)
    local ss, mm, hh = 0, 0, 0
    ss = string.format("%02d", Seconds % 60)
    mm = string.format("%02d", math.floor((Seconds % 3600) / 60))
    hh = string.format("%02d", math.floor(Seconds / 3600))
    return ss, mm, hh
end

function xprint(PlayerIndex, Message, Enviroment)
	if tonumber(PlayerIndex) ~= 0 then
		if tonumber(Enviroment) ~= 2 then
			rprint(PlayerIndex, Message)
		else
			say(PlayerIndex, compatable_message(Message))
		end
	else
		cprint(compatable_message(Message), 14)
	end
end

function compatable_message(Message)
	local Message = string.gsub(tostring(Message), "|t", "	")
	return Message -- So we dont get other useless shit from gsub
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

