
-- Anti-lagspawn by Devieth
-- Script for SAPP

api_version = "1.10.0.0"
stand_ticks = {}
ce, client_machineinfo_size = 0x40, 0xEC

function OnScriptLoad()
	safe_write(true) safe_read(true)
	if halo_type == "PC" then ce, client_machineinfo_size = 0x0, 0x60 end
	register_callback(cb['EVENT_PRESPAWN'], "OnPrespawn")
	register_callback(cb['EVENT_TICK'], "OnEventTick")
end

function p_rint(msg) print(msg) end

function OnPrespawn(PlayerIndex)
	stand_ticks[PlayerIndex] = 15
end

function OnEventTick()
	for i = 1,16 do
		if player_alive(i) then
			if read_bit(getdynamicplayer(i) + 0x208, 0) then
				if stand_ticks[i] then
					if stand_ticks[i] > 0 then
						stand_ticks[i] = stand_ticks[i] - 1
						if stand_ticks[i] > 2 then
							force_stand(i)
						else
							allow_crouch(i)
						end
					end
				else stand_ticks[i] = 0 end
			end
		end
	end
end

function force_stand(PlayerIndex) -- Does not sync with client
	local client_machineinfo = get_client_magineinfo(PlayerIndex)
	if client_machineinfo ~= nil and m_object ~= nil then
		write_bit(client_machineinfo + 0x24, 0, 0)
	end
end

function allow_crouch(PlayerIndex)
	if read_bit(getdynamicplayer(PlayerIndex) + 0x208, 0) then
		local client_machineinfo = get_client_magineinfo(PlayerIndex)
		if client_machineinfo ~= nil and m_object ~= nil then
			write_bit(client_machineinfo + 0x24, 0, 1)
		end
	end
	timer(33, "is_standing", PlayerIndex)
end

function is_standing(PlayerIndex)
	if not read_bit(getdynamicplayer(PlayerIndex) + 0x208, 0) then
		force_stand(PlayerIndex)
	end
end

function get_client_magineinfo(PlayerIndex)
	local network_struct = read_dword(sig_scan("F3ABA1????????BA????????C740??????????E8????????668B0D") + 3)
	local client_machineinfo = network_struct + 0x3B8 + ce + to_real_index(PlayerIndex) * client_machineinfo_size
	if client_machineinfo then
	return client_machineinfo else return nil
	end
end

function getdynamicplayer(PlayerIndex)
	if tonumber(PlayerIndex) then
		if tonumber(PlayerIndex) ~= 0 then
			local m_object = get_dynamic_player(PlayerIndex)
			if m_object ~= 0 then return m_object end
		end
	end
	return false
end
