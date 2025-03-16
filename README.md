# Makord (a [Godiscord](https://github.com/Shuflduf/Godiscord) fork!)
![logo](https://github.com/soymako/pseudo_host/blob/main/makord.png)

## Make a Discord bot directly in the [Godot Game Engine](https://godotengine.org/)!

# Examples
## Ping-Pong
```gdscript
extends Node

@onready var discord_bot: DiscordBot = $DiscordBot

func _ready() -> void:
    discord_bot.token = OS.get_environment("DISCORD_BOT_TOKEN")


func _on_discord_bot_message_recieved(message: DiscordMessage) -> void:
    if message.content == "!ping":
        message.reply("Pong!")
```
![image](https://github.com/user-attachments/assets/e536bff2-848e-40b0-9bda-44ad64d8a448)
## Custom command with options
![command](https://github.com/user-attachments/assets/bfe84aab-1ee1-434b-b0ce-4e5c4c70d241)
## Button to send message
![image](https://github.com/user-attachments/assets/6a4a944a-88ab-48ba-93cd-0a01af135d72)

