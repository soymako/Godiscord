extends DiscordComponent; class_name DiscordButtonComponent


var label:String
var style:int
# var custom_id:String
var url:String
var emoji:String


func _init(label:String = "Default", style:DiscordResource.Styles = DiscordResource.Styles.PRIMARY, custom_id:String = "default", url:String = "", emoji:String = ""):
  type = 2
  self.label = label
  self.style = style
  self.custom_id = custom_id
  url = url
  emoji = emoji

func _parse()->Dictionary:
  var result:Dictionary = {
    "type": type,
    "label": label,
    "style": style,
    "custom_id": custom_id
  }
  return result
