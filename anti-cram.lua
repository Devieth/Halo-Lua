
-- Anti-cram script by Devieth
-- Script for SAPP

crams = {}
--Types: 0 = All, 1 = Light, 2 = Heavy, 3 = Air
--Example: crams[x] = {x, y, z, r, type, map}
crams[1] = {40.2, -75.2, 0, 1, 0, "bloodgulch"}
crams[2] = {40.1, -82.75, 0, 1, 0, "bloodgulch"}
crams[3] = {95.5, -156.2, 0, 1, 0, "bloodgulch"}
crams[4] = {95.5, -162.75, 0, 1, 0, "bloodgulch"}
crams[5] = {-12.00, 4.88, -2.35, 5, 0, "dangercanyon"} --red tunnel danger canyon
crams[6] = {-12.00, -3.45, -2.24, 12, 2, "dangercanyon"} --anti-tank red danger canyon
crams[7] = {12.00, -3.45, -2.24, 12, 2, "dangercanyon"} --anti-tank blue danger canyon
crams[8] = {12.00, 4.88, -2.35, 5, 0, "dangercanyon"} --blue tunnel danger canyon
--crams[9] =

types = {}
types[1] = {1, "ghost_mp"}
types[2] = {1, "rwarthog"}
types[3] = {1, "mp_warthog"}
types[4] = {2, "scorpion_mp"}
types[5] = {3, "banshee_mp"}

api_version = "1.10.0.0"

function OnScriptLoad()
	register_callback(cb['EVENT_TICK'], "OnEventTick")
	register_callback(cb['EVENT_GAME_START'], "OnGameStart")
	if tonumber(get_var(0, "$running")) == 1 then OnGameStart() end
end

function OnScriptUnload() end

function OnGameStart()
	map = read_string(read_dword(sig_scan("B8??????00E8??????0032C983F813") + 0x1))
end

function OnEventTick()
	for i = 1,16 do
		if player_alive(i) then
			local m_object = get_dynamic_player(i)
			if tonumber(m_object) ~= 0 then
				if tonumber(read_char(m_object + 0x2F0)) ~= -1 then
					if cramming(m_object) then
						exit_vehicle(i)
					end
				end
			end
		end
	end
end

function cramming(m_object)
	local m_vehicle = get_object_memory(read_dword(m_object + 0x11C))
	for i = 1,#crams do
		local type = get_vehicle_type(m_vehicle)
		if crams[i][5] == type or crams[i][5] == 0 then
			if vehicle_in_sphere(m_vehicle, crams[i][1], crams[i][2], crams[i][3], crams[i][4]) and map == crams[i][6] then
				timer(100, "move_to_spawn", m_vehicle)
				return true
			end
		end
	end
	return false
end

function move_to_spawn(m_vehicle)
	local allow = true
	local driver = read_char(m_vehicle + 0x324)
	local gunner = read_char(m_vehicle + 0x328)
	if driver == -1 and gunner == -1 then
		local x,y,z = read_vector3d(m_vehicle + 0x5B4)
		write_vector3d(m_vehicle + 0x5c, x, y, z)
		write_float(m_vehicle + 0x4D4, 0)
		allow = false
	end
	return allow
end

function get_vehicle_type(m_vehicle)
	local ID = read_dword(m_vehicle)
	local tagarray = read_dword(0x40440000)
	for i=0,read_word(0x4044000C)-1 do
		local tag = tagarray + i * 0x20
		local tagid = read_dword(tag + 0xC)
		if ID == tagid then
			local tag_path = read_string(read_dword(tag + 0x10))
			local t = tokenizestring(tag_path, "\\")
			for x=1,#types do
				if t[3] == types[x][2] then
					vehi_type = types[x][1]
				end
			end
			break
		end
	end
	return vehi_type
end

function vehicle_in_sphere(m_vehicle, X, Y, Z, R)
	local x,y,z = read_vector3d(m_vehicle + 0x5c)
	if (X - tonumber(x))^2 + (Y - tonumber(y))^2 + (Z - tonumber(z))^2 <= R then
		return true
	end
	return false
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
