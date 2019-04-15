-- Anti-speedhack by Devieth
-- For SAPP

mode = "k" -- k, b or ipban

api_version = "1.10.0.0"
update_violation_count = {}
past_update = {}

function OnScriptLoad()
	register_callback(cb['EVENT_TICK'], "OnEventTick")
	timer(5000, "reset_violations")
end

function OnScriptUnload() end

function OnEventTick()
	for i = 1,16 do
		if player_present(i) then
			local m_player = get_player(i)
			local update = read_word(m_player + 0xF4)
			if past_update[i] then
				local difference = update - past_update[i]
				if difference == 2 then
					if update_violation_count[i] then
						update_violation_count[i] = update_violation_count[i] + 1
						if update_violation_count[i] >= 5 then
							update_violation_count[i] = 0
							execute_command(mode.." "..i.. " Speedhack")
						end
					else
						update_violation_count[i] = 1
					end
				end
			end
			past_update[i] = update
		end
	end
end

-- Reset violations in the case of errors caused by lag.
function reset_violations()
	update_violation_count = {}
	return true
end

