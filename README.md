# Godiscord
![logo](https://github.com/user-attachments/assets/aaf807af-890c-49b1-9e9a-6d5504b777e8)

## Make a Discord bot directly in the [Godot Game Engine](https://godotengine.org/)!

## Example
```gdscript
extends Node

@onready var discord_bot: DiscordBot = $DiscordBot

func _ready() -> void:
    discord_bot.token = OS.get_environment("DISCORD_BOT_TOKEN")


func _on_discord_bot_message_recieved(message: DiscordMessage) -> void:
    if message.content == "ping":
        message.reply("Pong!")
```
