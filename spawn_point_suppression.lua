-- CTF Spawn Point Suppression by Devieth
-- Script possible thanks to ralliedteams.lua by Kavawavi
-- Script for SAPP

api_version = "1.10.0.0"

spawns = {}

function OnScriptLoad()
	register_callback(cb['EVENT_GAME_START'], "OnGameStart")
	register_callback(cb['EVENT_PRESPAWN'],"OnPlayerSpawn")
	-- Only uncomment the following timer function if you plan on reloading the server
	-- and want the script to continue working or if you know your server will launch
	-- into a map instantly. Otherwise this will cause the server to crash.
	--timer(100, "get_spawns")
end

function OnGameStart()
	get_spawns()
end

function spawn_suppressed(X,Y,Z,team)
	local suppressed = false
	for x = 1,16 do
		if player_present(x) then
			-- Is the player on the same team as the spawn point?
			if read_byte(get_player(x) + 0x20) == tonumber(team) then
				local m_object = get_dynamic_player(x)
				-- Is the player alive/have an object?
				if m_object ~= 0 then
					-- Have their shields or health taken damage in the last 2.5 seconds?
					if read_byte(m_object + 0xFC) ~= 255 or read_byte(m_object + 0x100) ~= 255 then
						local x,y,z = read_vector3d(m_object + 0x5C)
						-- Are they in the the radius of a spawn?
						if in_sphere(x,y,z,X,Y,Z,5) then
							-- If so set suppressed to true and stop the loop.
							suppressed = true
							break
						end
					end
				end
			end
		end
	end
	-- Return suppresed value.
	return suppressed
end

function spawn_occupied(team)
	local spawn_points = {}
	local purge = {}
	for i = 1,#spawns do
		-- Only include spawns that are on the players team.
		if spawns[i][5] == team then
			local x,y,z,r = spawns[i][1],spawns[i][2],spawns[i][3],spawns[i][4]
			spawn_points[#spawn_points+1] = {x,y,z,r}
		end
	end
	for i = 1,16 do
		if player_present(i) then
			local m_object = get_dynamic_player(i)
			-- Is the player alive/have a object attatched to them.
			if m_object ~= 0 then
				local x,y,z = read_vector3d(m_object + 0x5c)
				for j = 1,#spawn_points do
					local X,Y,Z = spawn_points[j][1],spawn_points[j][2],spawn_points[j][3]
					-- If the spawn is being blocked by ANYONE, mark it to be removed or
					-- if the spawn is under suppression mark it to be removed.
					if in_sphere(x,y,z,X,Y,Z,1) or spawn_suppressed(X,Y,Z,team) then
						purge[#purge+1] = j
					end
				end
			end
		end
	end
	-- Loop though the spawns marked and remove them from the spawn_points table.
	for i = 1,#purge do
		table.remove(spawn_points, purge[i])
	end
	-- Send valid spawn_points table back to be used.
	return spawn_points
end

function in_sphere(x, y, z, X, Y, Z, R)
	if (X - tonumber(x))^2 + (Y - tonumber(y))^2 + (Z - tonumber(z))^2 <= R then
		return true
	end
	return false
end

function OnPlayerSpawn(PlayerIndex)
	local team = read_byte(get_player(PlayerIndex) + 0x20)
	local m_object = get_dynamic_player(PlayerIndex)
	if m_object ~= 0 then -- Check if the player have an object assigned to them.
		local team = read_byte(get_player(PlayerIndex) + 0x20)
		local x,y,z = read_vector3d(m_object + 0x5C)
		if spawn_suppressed(x,y,z,team) then -- Check if the default spawn Halo provided is under suppression.
			local spawn_points = spawn_occupied(team) -- Get the table of valid spawn points that are not blocked or suppressed.
			local spawn = rand(1,#spawn_points+1) -- Use +1 because SAPP will NEVER pick the highest value given.
			-- Write the player coords and rotation to the new location.
			write_vector3d(m_object + 0x5C, spawn_points[spawn][1], spawn_points[spawn][2], spawn_points[spawn][3])
			write_vector3d(m_object + 0x74, math.cos(spawn_points[spawn][4]), math.sin(spawn_points[spawn][4]), 0)
		end
	end
end

function CTF_Spawn(starting_location)
	local CTF = false
	for i = 0,3 do
		if read_word(starting_location + 0x14 + (i*0x2)) == 1 or read_word(starting_location + 0x14 + (i*0x2)) == 12 then
			CTF = true
			break
		end
	end
	return CTF
end

function get_spawns()
	spawns = {}
    local tag_array = read_dword( 0x40440000 )
    local scenario_tag_index = read_word( 0x40440004 )
    local scenario_tag = tag_array + scenario_tag_index * 0x20
    local scenario_tag_data = read_dword(scenario_tag + 0x14)

    local starting_location_reflexive = scenario_tag_data + 0x354
    local starting_location_count = read_dword(starting_location_reflexive)
    local starting_location_address = read_dword(starting_location_reflexive + 0x4)

    for i=0,starting_location_count do
        local starting_location = starting_location_address + 52 * i
		local x,y,z = read_vector3d(starting_location)
		local r = read_float(starting_location + 0xC)
		local team = read_word(starting_location + 0x10)
		-- Check if the spawn is for CTF, if so then add it to the list of spawns.
		if CTF_Spawn(starting_location) then
			spawns[#spawns+1] = {x,y,z,r,team}
		end
    end
end
