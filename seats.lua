-- Drive from any seat by Devieth
-- Script for SAPP

drive_as_gunner = true -- Lets the gunner drive the hog (if there is no driver)
drive_as_passenger = false -- Lets the passender drive the hog (if there is no driver)
set_passenger_in_driver_seat = false-- Sets the passenger in the driver seat (if there is no driver)
set_passenger_in_gunner_seat = false -- Sets the passenger in gunner seat (if there is a driver)

api_version = "1.10.0.0"

function OnScriptLoad()
    register_callback(cb['EVENT_VEHICLE_ENTER'], "OnVehicleEnter")
end

function OnScriptUnload()end

function OnVehicleEnter(PlayerIndex, Seat)
	local m_object = get_dynamic_player(PlayerIndex)
	if m_object ~= 0 then
		local m_vehicleId = read_dword(m_object + 0x11C)
		if m_vehicleId ~= 0 then
			local m_vehicle = get_object_memory(m_vehicleId)
			if m_vehicle ~= 0 then
				local driver = read_dword(m_vehicle + 0x324)
				local gunner = read_dword(m_vehicle + 0x328)
				if Seat == "2" then
					if drive_as_gunner then
						if driver == 0xFFFFFFFF then
							enter_vehicle(m_vehicleId, PlayerIndex, 0)
							exit_vehicle(PlayerIndex)
							enter_vehicle(m_vehicleId, PlayerIndex, 0)
							enter_vehicle(m_vehicleId, PlayerIndex, 2)
						end
					end
				elseif Seat == "1" then
					if set_passenger_in_driver_seat or set_passenger_in_gunner_seat then
						if driver == 0xFFFFFFFF then
							enter_vehicle(m_vehicleId, PlayerIndex, 0)
						else
							if gunner == 0xFFFFFFFF then
								enter_vehicle(m_vehicleId, PlayerIndex, 2)
							end
						end
					elseif drive_as_passenger and not set_passenger_in_driver_seat then
						if driver == 0xFFFFFFFF then
							enter_vehicle(m_vehicleId, PlayerIndex, 0)
							exit_vehicle(PlayerIndex)
							enter_vehicle(m_vehicleId, PlayerIndex, 0)
							enter_vehicle(m_vehicleId, PlayerIndex, 1)
						end
					end
				elseif Seat == "0" then
					if driver ~= 0xFFFFFFFF then
						exit_vehicle(PlayerIndex)
					else
						say(PlayerIndex, "There is already a driver.")
					end
				end
			end
		end
	end

end
