
-- Votekick
-- SAPP Compatability: 8.6+
-- Script by: Skylace aka Devieth
-- Discord: https://discord.gg/Mxmuxgm

start_votekick_command = "/votekick" -- Command used to start a votekick
vote_yes_command = "/kick" -- Command to vote yes to kick the player.
votekick_needed = 0.7 -- Persentage of total players needed.
votekick_timeout = 1 -- Minutes before a votekick expires.

votes = 0
voted = {}

api_version = "1.10.0.0"

function OnScriptLoad()
	victim = nil
	victim_name = nil
	execute_command("setcmd pl -1") -- Allows all players to use /pl command.
	register_callback(cb['EVENT_CHAT'], "OnChat")
	register_callback(cb['EVENT_JOIN'], "OnJoin")
	register_callback(cb['EVENT_LEAVE'], "OnLeave")
end

function OnJoin(PlayerIndex)
	voted[PlayerIndex] = false
end

function OnLeave(PlayerIndex)
	if voted[PlayerIndex] then votes = votes -1 end
end

function OnChat(PlayerIndex, Message)
	local allow = true
	if PlayerIndex ~= "-1" then
		local t = tokenizestring(string.lower(Message), " ")
		if t[1] == start_votekick_command then
			allow = false
			if tonumber(get_var(PlayerIndex, "$pn")) > 2 then
				if tonumber(t[2]) ~= nil then -- Make sure they didnt forget to add the victim's player number.
					if tonumber(t[2]) > 0 and tonumber(t[2]) < 17 then -- Make sure its within a valid player number range.
						victim_name = get_var(t[2], "$name")
						victim = t[2]
						if votes == 0 then
							local needed = math.floor(tonumber(get_var(PlayerIndex, "$pn")) * votekick_needed)
							if PlayerIndex ~= t[2] then
								say_all(get_var(PlayerIndex, "$name") .. " has started a votekick on " .. victim_name .. "! 1 of " .. needed .. " votes needed to kick!")
							else
								say_all(get_var(PlayerIndex, "$name") .. " has started a votekick on himself! 1 of " .. needed .. " votes needed to kick!") -- Yep, if they want to kick themselves, let them.
							end
							say_all("Type "..vote_yes_command.." in chat to votekick " .. victim_name.. "!")
							timer(votekick_timeout*60*1000, "timeout", false)
							voted[PlayerIndex] = true
							votes = votes + 1
						else
							say(PlayerIndex, "A votekick on " .. victim_name .. " is already active. Try again latter.")
						end
					else
						say(PlayerIndex, "Invalid player! Use /pl to get valid players.")
					end
				else
					say(PlayerIndex, "Error: Please use the player's number. Use /pl to display player numbers.")
				end
			else
				say(PlayerIndex, "Error: Not enough players to start a votekick")
			end
		elseif t[1] == vote_yes_command then
			if votes ~= 0 then
				if not voted[PlayerIndex] then
					votes = votes + 1
					voted[PlayerIndex] = true
					local needed = math.floor(tonumber(get_var(PlayerIndex, "$pn")) * votekick_needed)
					if tonumber(votes) >= tonumber(needed) then
						say_all("Enough votes to kick " .. victim_name .. "!")
						execute_command("k ".. victim .." 'Votekick'")
						timeout(true)
					else
						say_all(votes .. "of " .. needed .. " votes needed to kick " .. victim_name .. "!")
					end
				else
					say(PlayerIndex, "You have already voted to kick "..victim_name..".")
				end
			else
				say(PlayerIndex, "There are no currently active votekicks.")
			end
		end
	end
	return allow
end

function timeout(Kicked)
	if victim ~= nil then
		if not Kicked then
			for i = 1,16 do voted[i] = false end
			say_all("The votekick on "..victim_name.." has expired!")
			victim = nil
			victim_name = nil
			votes = 0
		else
			for i = 1,16 do voted[i] = false end
			victim = nil
			victim_name = nil
			votes = 0
		end
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
