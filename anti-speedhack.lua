-- Anti-speedhack by Devieth
-- For SAPP

api_version = "1.10.0.0"
update_violation_count = {}
past_update = {}
reset = {}

function OnScriptLoad()
	register_callback(cb['EVENT_TICK'], "OnEventTick")
	register_callback(cb['EVENT_LEAVE'], "OnPlayerLeave")
end

function OnScriptUnload() end

function OnPlayerLeave(PlayerIndex)
	if reset[tonumber(PlayerIndex)] ~= nil then
		if reset[tonumber(PlayerIndex)] > 1 then
			reset[tonumber(PlayerIndex)] = nil
		end
	end
end

function OnEventTick()
	for i = 1,16 do
		if player_present(i) then
			if reset[i] ~= nil then
				if reset[i] >= 1 then
					for x = 2,26 do rprint(i, " ") end
					rprint(i, "|cYou have been reset!|ncff0000")
					rprint(i, "|tPossible issues:|tPlease fix in: "..math.floor(reset[i]/30))
					rprint(i, "|tPacket loss/lag.")
					rprint(i, "|tSpeed-hacking.")
					reset[i] = reset[i] - 1
				end
			end
			local m_player = get_player(i)
			local update = read_word(m_player + 0xF4)
			if past_update[i] then
				local difference = update - past_update[i]
				if difference >= 2 then
					if update_violation_count[i] ~= nil then
						update_violation_count[i] = update_violation_count[i] + 1
						if update_violation_count[i] > 5 then
							if reset[i] == nil then
								reset[i] = 30*30
								destroy_object(read_dword(get_player(i) + 0x34))
							else
								if reset[i] < 1 then
									say_all("Autokick: "..get_var(i,"$name").. " was kicked due to lag or speed-hack.")
									execute_command("sv_kick "..i)
								end
							end
							update_violation_count[i] = 0
						end
					else
						update_violation_count[i] = 1
					end
				end
			end
			if update_violation_count[i] ~= nil then
				if update_violation_count[i] > 0 then
					if update == 32 or update == 63 then
						update_violation_count[i] = update_violation_count[i] - 1
					end
				end
			end
			past_update[i] = update
		end
	end
end
