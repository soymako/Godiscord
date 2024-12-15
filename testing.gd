extends Node

@onready var discord_bot: DiscordBot = $DiscordBot

func _ready() -> void:
	discord_bot.token = OS.get_environment("DISCORD_BOT_TOKEN")

func _on_discord_bot_message_recieved(message: DiscordMessage) -> void:
	if message.author.id != discord_bot.user.id:
		message.reply("You said: " + message.content)

func _on_discord_bot_bot_ready() -> void:
	var options := [
		{
			"name": "option",
			"description": "this is required",
			"type": 3,
			"required": true,
		}
	]
	discord_bot.register_slash_command("hello", "Says hello", options)
	discord_bot.register_slash_command("bye", "Says goodbye")


func _on_discord_bot_command_used(command: DiscordCommandRequest) -> void:
	if command.name == "hello":
		command.reply("HELLO " + str(command.options["option"]))
	elif command.name == "bye":
		command.reply("BYe " + command.caller.name)
