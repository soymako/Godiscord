class_name DiscordEmbedField
extends Resource

@export var name:String
@export var value:String
@export var inline:bool

func _init(name:String = "default", value:String = "default value", inline:bool = false) -> void:
  self.name = name
  self.value = value
  self.inline = inline
