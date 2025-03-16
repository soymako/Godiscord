extends DiscordComponent; class_name DiscordStringSelectComponent

# var custom_id:String
var options:Array[DiscordStringSelectOptionComponent]

func _init(custom_id:String = "default", options:Array[DiscordStringSelectOptionComponent] = []) -> void:
  type = 3
  self.custom_id = custom_id
  self.options = options

func _parse()->Dictionary:
  var result:Dictionary = {
    "type": type,
    "custom_id": custom_id
  }
  result["options"] = []
  for option:DiscordStringSelectOptionComponent in options:
    print("option: ", option)
    result["options"].append(option._parse())
  return result