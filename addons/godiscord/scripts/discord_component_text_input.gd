extends DiscordComponent; class_name DiscordTextInputComponent

# var custom_id:String
var title:String

func _init(title:String = "Default Title", custom_id:String = "default_text_input", components: Array[DiscordComponent] = []) -> void:
  type = 4
  self.title = title
  self.custom_id = custom_id
  self.components = components

func _parse()->Dictionary:
  var result:Dictionary = {
    "type": type,
    "title": title,
    "custom_id": custom_id
  }
  result["components"] = []
  for component:DiscordComponent in components:
    result["components"].append(component._parse())
  return result
