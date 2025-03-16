class_name DiscordComponent
extends Resource

var type: int = 1
var components: Array[DiscordComponent]

var custom_id: String

enum ComponentTypes{
  ACTION_ROW = 1,
  BUTTON = 2,
  STRING_SELECT = 3,
  TEXT_INPUT = 4,
  USER_SELECT = 5,
  ROLE_SELECT = 6,
  MENTIONABLE_SELECT = 7,
  CHANNEL_SELECT = 8
}

func _init(components: Array[DiscordComponent] = []):
  self.components = components

func _parse()->Dictionary:
  var result:Dictionary = {}
  result["type"] = type
  result["components"] = []
  for component:DiscordComponent in components:
    result["components"].append(component._parse())
  return result

func _parse_component(component:DiscordComponent)->Dictionary:
  return component._parse()
