-- Game Progression Clock by Devieth
-- Script for SAPP

api_version = "1.10.0.0"

game_over = false
clock_mode = {}

function OnScriptLoad()
	register_callback(cb['EVENT_TICK'], "OnEventTick")
	register_callback(cb['EVENT_GAME_START'], "OnGameStart")
	register_callback(cb['EVENT_GAME_END'], "OnGameEnd")
	register_callback(cb['EVENT_CHAT'], "OnPlayerChat")
end

function OnGameStart()
	game_over = false
end

function OnGameEnd()
	game_over = true
end

function OnPlayerChat(PlayerIndex, Message)
	local allowed = true
	if Message == nil then allowed = false end
	local Command = chat_command(Message)
	if Command ~= nil then
		local t = tokenizestring(string.lower(Command), " ")
		if t[1] == "clock" then
			if t[2] then
				local number = tonumber(t[2])
				if number == 0 or number == 1 then
					clock_mode[get_var(PlayerIndex, "$name")] = number
				end
			end
		end
	end
	return allowed
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

function chat_command(Message)
	local fixed = nil
	if string.sub(Message,0,1) == '/' then
		fixed = string.gsub(Message, '/', "")
	elseif string.sub(Message,0,1) == '\\' then
		fixed = string.gsub(Message, '\\', "")
	end
	return fixed
end

function OnEventTick()
	local Time1, Time2 = Time()
	if not game_over then
		for i = 1,16 do
			if player_present(i) then
				local PlayerIndex = get_var(i, "$name")
				if clock_mode[PlayerIndex] ~= nil then
					if clock_mode[PlayerIndex] == 0 then
						local ss, mm, hh = time_stamp(Time1)
						for x = 0,26 do rprint(i, " ") end
						rprint(i, "|r"..mm..":"..ss)
					else
						local ss, mm, hh = time_stamp(Time2)
						for x = 0,26 do rprint(i, " ") end
						rprint(i, "|r"..mm..":"..ss)
					end
				else
					clock_mode[PlayerIndex] = 0
				end
			end
		end
	end
end

function time_stamp(Seconds)
    local ss, mm, hh = 0, 0, 0

    ss = Seconds % 60
    mm = math.floor((Seconds % 3600) / 60)
    --hh = math.floor(Seconds / 3600)

    ss = string.format("%02d", ss)
    mm = string.format("%02d", mm)
    --hh = string.format("%02d", hh)

    return ss, mm, hh
end

function Time()
	local gametype_base = read_dword(read_dword(sig_scan("A1????????8B480C894D00") + 0x1))
	local reset_tick = read_dword(read_dword(sig_scan("8B510C6A018915????????E8????????83C404") + 7))
	local ticks_passed = read_dword(gametype_base + 0xC)
	local time_passed = (ticks_passed - reset_tick) / 30
	local time_limit = read_dword(0x5F54F0) / 30
	local time_left = time_limit - tonumber(time_passed)
	return time_left, time_passed
end
