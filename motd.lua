
-- Referance: 64, 96, 128, 160, 192, 224, 256, 288, 320, 384
buffer = 288 -- Raise this if your message is being cut off before it has finished sliding out.
char_reset = 128 -- Maximum invisable characters (You want this to be equal or greater than the char_max.)
char_max = 128 -- Maximum visable characters.

-- Set to false to debug your messages (if they are typing below the motd box.)
-- Yellow = There may be text being written on a non-visable line.
-- Red = There is to many lines and the script IS 100% writting text on a non-visable line.
disable_warnings = true

-- Use |n after each line to start a new line.
-- Place your message withing the double brackes [[ ]]
-- Make each line long enough according to your char_max
message = [[
I hear the drums echoing tonight|n
But she hears only whispers of some quiet conversation|n
She's coming in, 12:30 flight|n
The moonlit wings reflect the stars that guide me towards salvation|n
I stopped an old man along the way|n
Hoping to find some long forgotten words or ancient melodies|n
He turned to me as if to say, 'Hurry boy, it's waiting there for you'|n
|n
It's gonna take a lot to take me away from you|n
There's nothing that a hundred men or more could ever do|n
I bless the rains down in Africa|n
Gonna take some time to do the things we never had|n
|n
The wild dogs cry out in the night|n
As they grow restless, longing for some solitary company|n
I know that I must do what's right|n
As sure as Kilimanjaro rises like Olympus above the Serengeti|n
I seek to cure what's deep inside, frightened of this thing that I've become|n
|n
It's gonna take a lot to drag me away from you|n
There's nothing that a hundred men or more could ever do|n
I bless the rains down in Africa|n
Gonna take some time to do the things we never had|n
|n
Hurry boy, she's waiting there for you|n
It's gonna take a lot to drag me away from you|n
There's nothing that a hundred men or more could ever do|n
I bless the rains down in Africa|n
I bless the rains down in Africa|n
(I bless the rain)|n
I bless the rains down in Africa|n
(I bless the rain)|n
I bless the rains down in Africa|n
I bless the rains down in Africa|n
(Ah, gonna take the time)|n
Gonna take some time to do the things we never had
]]

-- do not touch these values
api_version = "1.10.0.0"
warning_count = 0
error_count = 0
char_min = 1
bl = ""

function OnScriptLoad()
	for i = 1,char_reset do
		bl = bl.." "
	end
	timer(500, "motd")
end

function OnScriptUnload() end


function motd()
	char_min, char_max = char_min + 1, char_max + 1
	if char_max >= buffer + string.len(message) then
		char_min, char_max = 1, char_reset
	end

	local message_str = string.sub(bl..message..bl, char_min, char_max)
	if not disable_warnings then
		local str, error_lvl = string.gsub(message_str, "|n", "")
		if error_lvl == 4 then
			warning_count = warning_count + 1
			cprint("WARNING ("..warning_count.."): There may be to many lines in the motd! Lines: "..error_lvl, 6)
		elseif error_lvl >= 5 then
			error_count = error_count + 1
			cprint("ERROR: ("..error_count.."): There are to many lines in th motd! Lines: "..error_lvl, 4)
		end
	end
	execute_command('motd "|c'..message_str..'"')
	return true
end
