@tool
extends EditorPlugin

func _enable_plugin() -> void:
    add_autoload_singleton("DiscordRequestHandler", "scripts/discord_request_handler.gd")


func _disable_plugin():
    remove_autoload_singleton("DiscordRequestHandler")


func _enter_tree() -> void:
    add_custom_type("DiscordBot", "Node", preload("scripts/discord_bot.gd"), preload("assets/discord_base.svg"))


func _exit_tree() -> void:
    remove_custom_type("DiscordBot")
