-- Map Downloader by Devieth
-- For SAPP

-- Required files:
-- wget.exe
-- 7z.exe
-- 7z.dll

map_repo = "http://maps.halonet.net/maps/" -- Hac2 Repo
api_version = "1.10.0.0"

function OnScriptLoad()
	register_callback(cb['EVENT_COMMAND'], "OnEventCommand")
	maps_folder_path = read_string(0x5B9610).."\\maps\\"
end

function OnScriptUnload() end

-- Enviroment
-- 0 = Console
-- 1 = RCON Console
-- 2 = Chat
function OnEventCommand(PlayerIndex, Command, Enviroment, Password)
	local t = tokenizestring(string.lower(string.gsub(Command, [["]], "")), " ")
	if get_var(PlayerIndex, "$lvl") ~= "-1" or tonumber(Enviroment) == 0 then

		-- Hi-Jack SAPP's command.
		if t[1] == "map_download" then

			-- Make sure they actuall used a name
			if t[2] then
				local downloaded, map_name = false, tostring(t[2])

				-- Download the map.
				local map = assert(io.popen('wget -c '..map_repo..map_name..'.zip'))
				map:close()

				-- Check if the download was successful.
				local file = io.open(map_name..".zip")
				if file then
					downloaded = true
					file:close()
				end

				if downloaded then
					-- Unzip the map.
					local sevenz = assert(io.popen('7z.exe e '..tostring(t[2])..'.zip -o'..maps_folder_path))
					sevenz:close()

					-- Load the map.
					execute_command("map_load "..map_name)
					rcon_return(tonumber(Enviroment), PlayerIndex, "Download of "..map_name.. " complete!")

					-- Delete the .zip file.
					os.remove(map_name..".zip")
				else

					-- Alert the usere that the download failed.
					rcon_return(tonumber(Enviroment), PlayerIndex, "Failed to download "..map_name)
					rcon_return(tonumber(Enviroment), PlayerIndex, "Map not on repo or was misspelled.")
				end
				return false
			else
				rcon_return(tonumber(Enviroment), PlayerIndex, "map_download <map name>")
				return false
			end
		end
	end
end

function rcon_return(Enviroment, PlayerIndex, Message)
	local Compatable_Message = string.gsub(tostring(Message), "|t", "	")
	if Enviroment == 0 then
		cprint(Compatable_Message,14)
	elseif Enviroment == 1 then
		rprint(PlayerIndex, Message)
	elseif Enviroment == 2 then
		say(PlayerIndex, Compatable_Message)
	end
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
