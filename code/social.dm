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
	inform(mob/user, message)
		user << {"<span class="feedback">[message]</span>"}
client/New()
	. = ..()
	motd(src)
	world << {"<span class="traffic">[key] has logged in</span>"}
	// TODO: Separate out traffic
client/Del()
	world << {"<span class="traffic">[key] has logged out</span>"}
	// TODO: Separate out traffic
	. = ..()
// End MOTD

client
	script = 'style.dms'
	var/tmp
		// see _defines.dm for constants
		chat_cooldown = CHAT_COOLDOWN // half a second is more than enough time
		next_chat_time // can't chat before this time

	verb
		say(message as text)
			// enforce cooldown
			if(world.time > next_chat_time)
				// start cooldown
				next_chat_time = world.time + chat_cooldown
				// filter out "\n" and HTML and enforce max length
				var/filtered_message = copytext(message, 1, MAX_CHAT_LENGTH)
				if(length(filtered_message) != length(message))
					inform(src, "Your message was too long, and has been shortened.")
				filtered_message = html_encode(text_replace(filtered_message, "\n", "\\n"))
				// TODO: Remove extra whitespace. Ie, messages that are nothing but white space.
				if(!length(filtered_message)) return
				hearers(world.view+2, mob) << {"<span class="say"><b>[key]</b>: [filtered_message]"}

			else
				// explain cooldown
				var time_left = round(world.time - next_chat_time) / -10
				inform(src, "Please wait [time_left]s before writing another message.")

		say_alias_1(message as text)
			set name = "S"
			set hidden = TRUE
			say(message)

		worldsay(message as text)
			set name = "World Say"
			// enforce cooldown
			if(world.time > next_chat_time)
				// start cooldown
				next_chat_time = world.time + chat_cooldown
				// filter out "\n" and HTML and enforce max length
				var/filtered_message = html_encode(copytext(text_replace(message, "\n", "\\n"), 1, MAX_CHAT_LENGTH))
				// TODO: Remove extra whitespace. Ie, messages that are nothing but white space.
				if(!length(filtered_message)) return
				world << {"<span class="worldsay"><b>[key]</b>: [filtered_message]"}

			else
				// explain cooldown
				var time_left = round(world.time - next_chat_time) / -10
				inform(src, "Please wait [time_left]s before writing another message.</span>")

		worldsay_alias_1(message as text)
			set name = "W"
			set hidden = TRUE
			worldsay(message)

		who()
			usr << "<b>Logged in Players</b>:"
			for(var/client/C)
				usr << " -- <b>[html_encode(C.key)]</b> \[[C.connection]\]"