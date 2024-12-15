extends Control

@onready var discord_bot: DiscordBot = $DiscordBot

func _on_discord_bot_message_recieved(message: DiscordMessage) -> void:
	if message.author.id != discord_bot.user.id:
		message.reply("You said: " + message.content)

func _on_discord_bot_bot_ready() -> void:
	discord_bot.register_slash_command("hello", "Says hello")
	discord_bot.register_slash_command("bye", "Says goodbye")


func _on_discord_bot_command_used(command: DiscordCommandRequest) -> void:
	#command.handle_interaction()
	if command.name == "hello":
		command.reply("HEI")
	elif command.name == "bye":
		command.reply("BY")
