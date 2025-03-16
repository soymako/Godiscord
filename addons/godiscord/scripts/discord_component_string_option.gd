extends DiscordComponent; class_name DiscordStringSelectOptionComponent

var label: String
var description: String
var value: String
var emoji: String

func _init(label: String, description: String, value: String, emoji: String = "") -> void:
    self.label = label
    self.description = description  # ¡Faltaba!
    self.value = value              # ¡Faltaba!
    self.emoji = emoji

func _parse() -> Dictionary:
    var result: Dictionary = {
        "label": label,
        "value": value,
        "description": description  # ¡Se había omitido!
    }
    if !emoji.is_empty():
        result["emoji"] = emoji
    return result
