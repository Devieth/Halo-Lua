
-- TK_Kick by Devieth
-- Script for SAPP
api_version = "1.10.0.0"

-- Amount of team kills (betrays) needed to get the option to kick a player.
tk_allow_kick = 3

-- TK_count
tk_count = {}

function OnScriptLoad()
	register_callback(cb['EVENT_CHAT'],"OnChat")
	register_callback(cb['EVENT_DIE'],"OnDeath")
	register_callback(cb['EVENT_JOIN'],"OnJoin")
end

function OnChat(PlayerIndex, Message)
	local allo = true
	if string.lower(Message) == "/tk_kick" then
		if last_tk_er ~= nil then
			if get_team(last_tk_er) == get_team(PlayerIndex) then
				say_all(get_name(last_tk_er).. " has been kicked by his team for betraying!")
				execute_command("k "..last_tk_er.." tk_kick")
			else
				say(PlayerIndex, "You cannot kick "..get_name(last_tk_er).. " because he is not on your team.")
			end
		else
			say(PlayerIndex, "There is no one to kick for team killing.")
		end
		allow = false
	end
	return allow
end

function OnDeath(PlayerIndex, KillerIndex)
	if get_var(1, "$ffa") ~= "1" then
		if PlayerIndex ~= nil and PlayerIndex ~= "-1" then
			if KillerIndex ~= nil and KillerIndex ~= "-1" then
				local vteam = get_team(PlayerIndex)
				local kteam = get_team(KillerIndex)
				local kname = get_name(KillerIndex)
				if vteam == kteam then
					if tk_count[kname] then
						tk_count[kname] = tonumber(tk_count[kname]) + 1
						if tonumber(tk_count[kname]) >= tk_allow_kick then
							last_tk_er = KillerIndex
							say(PlayerIndex, get_name(KillerIndex) .. " has " .. tk_count[kname] .. " team kills. You now have the option to kick them with /tk_kick")
						end
					else
						tk_count[kname] = 1
					end
				end
			end
		end
	end
end

function OnJoin(PlayerIndex)
	tk_count[get_name(PlayerIndex)] = 0
end

function get_team(PlayerIndex) -- Gets the team of the player.
	return get_var(PlayerIndex, "$team")
end

function get_name(PlayerIndex)
	return get_var(PlayerIndex, "$name")
end

function OnError(Message)
	say_all(Message)
end
