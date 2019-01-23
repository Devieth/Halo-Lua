
-- Commands by Devieth.
-- Script for SAPP
api_version = "1.10.0.0"

-- Vanished player list
player_vanished = {}
player_respawn_time = {}

function OnScriptLoad()
	register_callback(cb['EVENT_TICK'], "OnEventTick")
	register_callback(cb['EVENT_COMMAND'], "OnEventCommand")
	register_callback(cb['EVENT_DIE'], "OnPlayerDeath")
end

function OnScriptUnload() end -- We need this cause SAPP.

function OnEventCommand(PlayerIndex, Command, Enviroment, Password)
	-- Tokenize the string (and remove quotations.)
	local t = tokenizestring(string.lower(string.gsub(Command, '"', "")), " ")
	-- Get command mode (enable or disable.)
	local Command, Mode = process_command(t[1])
	-- Are they an admin or is this being executed from the console.
	if get_var(PlayerIndex, "$lvl") ~= "-1" or Enviroment == "0" then
		if Command == "vanish" then
			-- Execute the command.
			Message = command_vanish(t[2], PlayerIndex, Mode)
		elseif Command == "resp" then
			Message = command_respawn_time(t[2], PlayerIndex, t[3])
			Allow = false
		end
	end
	-- Wes a message return from the command.
	if Message then
		-- Return result to the executer.
		rcon_return(tonumber(Enviroment), PlayerIndex, Message)
		return false
	end
end

function OnEventTick()
	for i = 1,16 do
		if player_present(i) then
			if player_vanished[i] then
				-- Set player's visable bipd Z coord below the map.
				write_float(get_player(i) + 0x100, -1000)
			end
		end
	end
end

function OnPlayerDeath(VictimIndex, KillerIndex)
	if player_respawn_time[tonumber(VictimIndex)] then
		-- Set player respawn time.
		write_dword(get_player(VictimIndex) + 0x2C, player_respawn_time[tonumber(VictimIndex)] * 30)
	end
end

function command_vanish(TargetIndex, UserIndex, Mode)
	-- Is there a target?
	if TargetIndex then
		-- If so make sure they are a valid target.
		local PlayerIndex = get_valid_player(TargetIndex, UserIndex)
		if PlayerIndex then
			-- Mode 1 = enable
			if Mode == 1 then
				player_vanished[PlayerIndex] = true
				return get_name(PlayerIndex).. " has vanished."
			else -- mode 0 = disable
				player_vanished[PlayerIndex] = false
				return get_name(PlayerIndex).. " has unvanished."
			end
		end
		return "Error: Player is not present."
	end
	return "Error: No player specified."
end

function command_respawn_time(TargetIndex, UserIndex, Time)
	if TargetIndex then
		local PlayerIndex = get_valid_player(TargetIndex, UserIndex)
		if PlayerIndex then
			if tonumber(Time) then
				player_respawn_time[PlayerIndex] = tonumber(Time)
				return get_name(PlayerIndex).."'s respawn time set to "..tonumber(Time).." seconds."
			end
			player_respawn_time[PlayerIndex] = nil
			return get_name(PlayerIndex).."'s respawn time has been reset."
		end
		return "Error: Player is not present."
	end
	return "Error: No player specified."
end

function get_name(PlayerIndex)
	return get_var(PlayerIndex, "$name")
end

function get_valid_player(Player, UserIndex)
	local PlayerIndex = nil
	if Player ~= nil then
		if string.lower(Player) == "me" then
			return tonumber(UserIndex)
		end
		if tonumber(Player) then
			if tonumber(Player) > 0 and tonumber(Player) < 17 then
				if player_present(tonumber(Player)) then
					PlayerIndex = tonumber(Player)
				end
			end
		end
	end
	return PlayerIndex
end

function rcon_return(Enviroment, PlayerIndex, Message)
	local Compatable_Message = string.gsub(tostring(Message), "|t", "	")
	if Enviroment == 0 then -- Console
		cprint(Compatable_Message,14)
	elseif Enviroment == 1 then -- Rcon
		rprint(PlayerIndex, Message)
	elseif Enviroment == 2 then -- Chat
		say(PlayerIndex, Compatable_Message)
	end
end

function process_command(Command)
	if string.sub(Command, 1,2) == "un" then
		return string.sub(Command, 3, string.len(Command)), 0
	end
	return Command, 1
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
