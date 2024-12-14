extends Control

@onready var discord_bot: Node = $DiscordBot

func _on_discord_bot_message_recieved(message: DiscordMessage) -> void:
	if message.author.id != discord_bot.user.id:
		message.reply(message.content)
