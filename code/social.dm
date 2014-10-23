// Message of the Day //
var
	motd = {"
<b>
The game is a work in progress, and more is being added every day. What's new today?:
	A Social System (Thanks AlexanderPeterson and Kaiochao!)

Think you could make the game better? Let me know, it'd be great to have other players making the game. Or, you could just contribute to the GitHub repo, if that's how you roll.
	GitHub: <a href="https://github.com/jacobabrennan/carrot">https://github.com/jacobabrennan/carrot</a>
	BYOND Hub: <a href="http://www.byond.com/games/IainPeregrine/project_carrot">IainPeregrine.project_carrot</a>
	Email: <a href="email:jacobabrennan@gmail.com">JacobABrennan@gmail.com</a>
	BYOND Key: IainPeregrine
	"}
proc
	motd(client/client)
		client << "[motd]"
client/New()
	. = ..()
	motd(src)
	world << {"<i style="color:grey">[key] has logged in</i>"}
	// TODO: Separate out traffic
client/Del()
	world << {"<i style="color:grey">[key] has logged out</i>"}
	// TODO: Separate out traffic
	. = ..()
// End MOTD

client
	script = 'style.dms'
	var
		chat_delay = CHAT_DELAY // half a second is more than enough time
		next_chat // only allow chat beyond this time

	verb
		say(message as text)
			if(!message) return
			// Check length
			if(length(message) > MAX_MESSAGE_LENGTH)
				// Explain length
				usr << {"<span class="feedback">The message was too long. It has been shortened.</span>"}
				message = copytext(message, 1, MAX_MESSAGE_LENGTH)
			// Check Cooldown
			if(next_chat > world.time) // block chat
				var/cooldown_seconds = round((world.time - next_chat) / 10)
				if(cooldown_seconds < 1) cooldown_seconds = 1
				usr << {"<span class="feedback">Please wait [cooldown_seconds] second"} + (cooldown_seconds > 1 ? "s" : "") + {" before writing another message.</span>"}
				return
			else // allow chat
				next_chat = world.time + chat_delay
			// Remove Newlines
			var/nl_pos = findtext(message, "\n")
			while(nl_pos)
				message = copytext(message, 1, nl_pos)+copytext(message, nl_pos+1)
				nl_pos = findtext(message, "\n", nl_pos)
			// TODO: Remove extra whitespace. Ie, messages that are nothing but white space.
			if(!length(message))
				return
			// Passed all checks, output
			var/escapedMessage = html_encode(message)
			hearers(world.view+2, mob) << {"<span class="say"><b>[key]</b>: [escapedMessage]</span>"}
		say_alias_1(message as text)
			set name = "S"
			set hidden = TRUE
			say(message)
		worldsay(message as text)
			set name = "World Say"
			if(!message) return
			// Check length
			if(length(message) > MAX_MESSAGE_LENGTH)
				// Explain length
				usr << {"<span class="feedback">The message was too long. It has been shortened.</span>"}
				message = copytext(message, 1, MAX_MESSAGE_LENGTH)
			// Check Cooldown
			if(next_chat > world.time) // block chat
				var/cooldown_seconds = round((world.time - next_chat) / 10)
				if(cooldown_seconds < 1) cooldown_seconds = 1
				usr << {"<span class="feedback">Please wait [cooldown_seconds] second"} + (cooldown_seconds > 1 ? "s" : "") + {" before writing another message.</span>"}
				return
			else // allow chat
				next_chat = world.time + chat_delay
			// Remove Newlines
			var/nl_pos = findtext(message, "\n")
			while(nl_pos)
				message = copytext(message, 1, nl_pos)+copytext(message, nl_pos+1)
				nl_pos = findtext(message, "\n", nl_pos)
			// TODO: Remove extra whitespace. Ie, messages that are nothing but white space.
			if(!length(message))
				return
			// Passed all checks, output
			var/escapedMessage = html_encode(message)
			world << {"<span class="worldsay">(World) <b>[key]</b>: [escapedMessage]</span>"}
		worldsay_alias_1(message as text)
			set name = "W"
			set hidden = TRUE
			worldsay(message)
		who()
			for(var/client/C)
				usr << "<b>[html_encode(C.key)]</b> \[[C.connection]\]"