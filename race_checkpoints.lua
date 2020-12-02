-- Race Checkpoints
-- Script By: Devieth

api_version = "1.10.0.0"

checkpoint = {}
last_checkpoint = {}
spawned = {}

function OnScriptLoad()
	race_globals = 0x5BDFA0
	register_callback(cb['EVENT_SPAWN'], "OnPlayerSpawn")
	register_callback(cb['EVENT_TICK'], "OnTick")
	register_callback(cb['EVENT_VEHICLE_ENTER'], "OnEventVehicleEnter")
end

function OnScriptUnload() end

function OnPlayerSpawn(PlayerIndex)
	spawned[PlayerIndex] = true
end

function OnTick()
	for i = 1,16 do
		if player_alive(i) then
			local m_object = get_dynamic_player(i)
			if m_object ~= 0 then
				if last_checkpoint[i] == nil then last_checkpoint[i] = 0 end
				local current_checkpoint = read_dword(race_globals + to_real_index(i)*4 + 0x44)
				if current_checkpoint ~= last_checkpoint[i] then
					local m_vehicle = get_object_memory(read_dword(m_object + 0x11C))
					local x,y,z = read_vector3d(m_vehicle + 0x5C)
					local P,Y,R = read_vector3d(m_vehicle + 0x74)
					checkpoint[i] = {x,y,z,P,Y,R}
					last_checkpoint[i] = current_checkpoint
				end
			end
		end
	end
end

function OnEventVehicleEnter(PlayerIndex)
	local m_object = get_dynamic_player(PlayerIndex)
	local current_checkpoint = read_dword(race_globals + to_real_index(PlayerIndex)*4 + 0x44)
	if m_object ~= 0 then
		if spawned[PlayerIndex] == true and current_checkpoint ~= 0 then
			local x,y,z = checkpoint[PlayerIndex][1], checkpoint[PlayerIndex][2], checkpoint[PlayerIndex][3]
			local P,Y,R = checkpoint[PlayerIndex][4], checkpoint[PlayerIndex][5], checkpoint[PlayerIndex][6]
			local m_vehicle = get_object_memory(read_dword(m_object + 0x11C))
			write_vector3d(m_vehicle + 0x5c, x,y,z)
			write_vector3d(m_vehicle + 0x74, P,Y,R)
			spawned[PlayerIndex] =  false
		end
	end
end
