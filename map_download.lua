-- Map Downloader 2.0 by Devieth
-- For SAPP 10.x.x

-- HAC2 repo URL
hac2_repo = 'http://maps.halonet.net/' -- HAC2 Repo
-- If you have another source for these files feel free to use it.  `halopc.com` may not be up forever.
wget_dl = 'http://halopc.com/download/wget.exe'
unzip_dl = 'http://halopc.com/download/unzip.exe'
-- Sapp API min version.
api_version = '1.10.0.0'
script = 'map_download.lua: \t'

function OnScriptLoad()
	register_callback(cb['EVENT_COMMAND'], 'OnEventCommand')
	-- Assign the repo to use.
	map_repo = hac2_repo
	-- Get the EXE Path
	exe_path = read_string(read_dword(sig_scan('0000BE??????005657C605') + 0x3))
	-- Split the string
	local t = tokenizestring(exe_path, '\\')
	-- Create the maps_folder_path
	exe_folder_path = string.sub(exe_path, 0, string.len(exe_path) - string.len(t[#t]))
	maps_folder_path = string.sub(exe_path, 0, string.len(exe_path) - string.len(t[#t]))..'maps\\'
	-- Download unzip.
	get_required_files()
end

function OnScriptUnload() end

function tokenizestring(input_string, delimiter)
	if delimiter == nil then delimiter = '%s' end
	local t = {}
	for str in string.gmatch(input_string, '([^'..delimiter..']+)') do
		t[#t+1] = str
	end
	return t
end

function rcon_return(Enviroment, PlayerIndex, Message, Color)
	local Compatable_Message = string.gsub(tostring(Message), '|t', '	')
	if Color == nil then Color = 14 end
	if Enviroment == 0 then
		cprint(Compatable_Message, Color)
	elseif Enviroment == 1 then
		rprint(PlayerIndex, Message)
	elseif Enviroment == 2 then
		say(PlayerIndex, Compatable_Message)
	end
end

function download_file(url, path, filename, powershell)
	if filename == nil then filename = '' end
	if powershell then
		os.execute("powershell (New-Object System.Net.WebClient).DownloadFile('"..url.."','"..path..filename.."')")
	else
		local file = assert(io.popen('wget -O "'..filename..'" -c '..url))
		file:close()
		local file = io.open(path..filename)
		if file then
			local content_size = string.len(file:read('*all'))
			file:close()
			if content_size > 0 then
				return true
			else
				os.remove(filename)
				return false
			end
		end
		return false
	end
	cprint(script.."Download complete! Saving file to: "..path..filename, 14)
end

function get_required_files()
	local file = io.open('unzip.exe', 'r')
	if not file then
		cprint(script..'unzip.exe not present, attempting to download...', 4)
		download_file(unzip_dl, exe_folder_path, 'unzip.exe', true)
	else
		cprint(script..'unzip.exe found!',14)
		file:close()
	end
	local file = io.open('wget.exe', 'r')
	if not file then
		cprint(script..'wget.exe not present, attempting to download...', 4)
		download_file(wget_dl, exe_folder_path, 'wget.exe', true)
	else
		cprint(script..'wget.exe found!',14)
		file:close()
	end
end

function OnEventCommand(PlayerIndex, Command, Enviroment, Password)
	local t = tokenizestring(string.lower(string.gsub(Command, '"', '')), ' ')
	if get_var(PlayerIndex, '$lvl') ~= '-1' or tonumber(Enviroment) == 0 then
		-- Hi-Jack SAPP's command.
		if t[1] == 'map_download' then
			-- Make sure they actually used a name
			if t[2] then
				-- Download the map
				local map_name = t[2]
				-- Check if they already have the map, or wget is going to hold the server hostage.
				local file = io.open(maps_folder_path..map_name..'.map')
				if  file then
					file:close()
					rcon_return(tonumber(Enviroment), PlayerIndex, script..map_name.. " is already installed!")
					return false
				end
				-- Download the map.
				rcon_return(tonumber(Enviroment), PlayerIndex, script.."WARNING: Server may lag or disconnect durring download!")
				local downloaded = download_file(hac2_repo..'map_download.php?map='..map_name, exe_folder_path, map_name..'.zip')
				if downloaded then
					local unzip = assert(io.popen('unzip '..map_name..' -d '..maps_folder_path))
					unzip:close()
					-- Check to make sure the file was unziped.
					local file = io.open(maps_folder_path..map_name..'.map')
					if file then
						file:close()
						execute_command("map_load "..map_name)
						rcon_return(tonumber(Enviroment), PlayerIndex, script.."Download of "..map_name.. " complete!")
						-- Delete the .zip file.
						os.remove(map_name..'.zip')
					else
						rcon_return(tonumber(Enviroment), PlayerIndex, script..'Error: Failed to extract '..map_name..'.zip', 4)
					end
				else
					rcon_return(tonumber(Enviroment), PlayerIndex, script..'Error: Failed to download '..map_name..'\n'..script..'Please check your spelling or the hac2 repo if the map exist.', 4)
				end
			else
				rcon_return(tonumber(Enviroment), PlayerIndex, script..'Error: Please enter a map name.', 4)
			end
			return false
		end
	end
end
