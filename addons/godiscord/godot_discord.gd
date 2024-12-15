@tool
extends EditorPlugin

func _enable_plugin() -> void:
	add_autoload_singleton("DiscordRequestHandler", "scripts/discord_request_handler.gd")


func _disable_plugin():
	remove_autoload_singleton("DiscordRequestHandler")


func _enter_tree() -> void:
	add_custom_type("DiscordResource", "Resource", preload("scripts/discord_resource.gd"), preload("assets/discord_base.svg"))
	add_custom_type("DiscordChannel", "DiscordResource", preload("scripts/discord_channel.gd"), preload("assets/discord_base.svg"))
	add_custom_type("DiscordCommand", "DiscordResource", preload("scripts/discord_command_request.gd"), preload("assets/discord_base.svg"))
	add_custom_type("DiscordMessage", "DiscordResource", preload("scripts/discord_message.gd"), preload("assets/discord_base.svg"))
	add_custom_type("DiscordUser", "DiscordResource", preload("scripts/discord_user.gd"), preload("assets/discord_base.svg"))

	add_custom_type("DiscordBot", "Node", preload("scripts/discord_bot.gd"), preload("assets/discord_base.svg"))


func _exit_tree() -> void:
	remove_custom_type("DiscordResource")
	remove_custom_type("DiscordChannel")
	remove_custom_type("DiscordCommand")
	remove_custom_type("DiscordMessage")
	remove_custom_type("DiscordUser")

	remove_custom_type("DiscordBot")
