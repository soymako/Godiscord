class_name DiscordEmbed
extends Resource


var author_name: String
var author_icon_url: String
var thumbnail_url: String
var title: String
var description: String
var color: Color
var fields: Array[DiscordEmbedField]
var footer_text: String
var footer_icon_url: String

func _init(
author:String = "default",
author_icon:String = "",
thumbnail:String = "",
title:String = "default title",
description = "description not provided, using default",
color = Color.RED,
fields:Array[DiscordEmbedField] = [],
footer:String = "default footer text",
footer_icon:String = "") -> void:
  self.author_name = author
  self.author_icon_url = author_icon
  self.thumbnail_url = thumbnail
  self.title = title
  self.description = description
  self.color = color
  self.fields = fields
  self.footer_text = footer
  self.footer_icon_url = footer_icon
  pass

func color_to_decimal(color: Color) -> int:
  return (int(color.r * 255) << 16) | (int(color.g * 255) << 8) | int(color.b * 255)

func _parse()->Dictionary:
  var embed:Dictionary = {}

  if author_name or author_icon_url: embed["author"] = {
    "name": author_name if author_name else null,
    "icon_url": author_icon_url if author_icon_url else null
  }

  if thumbnail_url: embed["thumbnail"] = {
    "url": thumbnail_url
  }
  if title:
    embed["title"] = title
  if description:
    embed["description"] = description
  if color:
    embed["color"] = color_to_decimal(color)
  if fields.size() > 0:
    embed["fields"] = []
    for field in fields:
      embed["fields"].append({
        "name": field.name,
        "value": field.value,
        "inline": field.inline
      })

  if footer_text or footer_icon_url:
    embed["footer"] = {
      "text": footer_text if footer_text else null,
      "icon_url": footer_icon_url if footer_icon_url else null
    }

  return embed

    # var embed:Dictionary = {
    #   "author":{
    #     "name": "SoyMako",
    #     "icon_url": "https://i.imgur.com/lm8s41J.png"
    #   },
    #   "thumbnail": {
    #     "url": "https://i.imgur.com/lm8s41J.png"
    #   },
    #   "title": "hola",
    #   "color": color_to_discord_decimal(Color.AQUA),

    #   "description": "hola",
    #   "fields": [{
    #     "name": "campo 1",
    #     "value": "Valor 1",
    #     "inline": true
    #   }],
    #   "footer": {
    #     "text": "SoyMakoFooter",
    #     "icon_url": "https://i.imgur.com/lm8s41J.png"
    #   }
    # }
