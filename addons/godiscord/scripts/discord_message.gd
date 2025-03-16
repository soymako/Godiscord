class_name DiscordMessage
extends DiscordResource
## A Discord message

## Content of the message as a string.
## Godiscord does not currently support attachments, but it is a planned feature.
var content: String
## Channel where the message was sent
var channel: DiscordChannel
## The user who wrote the message
var author: DiscordUser
## ID of the message. Used for comparisons
var id: int

var guild:DiscordGuild

## Reply to the message.[br]
## [b]Example:[/b]
## [codeblock]
## func _on_discord_bot_message_recieved(message: DiscordMessage) -> void:
##     if message.author.id != discord_bot.user.id:
##         message.reply("You said: " + message.content)
## [/codeblock]
@warning_ignore("shadowed_variable")
func reply(content: String):
  var url = "https://discord.com/api/v9/channels/%s/messages" % channel.id
  var headers = [
    "Authorization: Bot %s" % token,
    "Content-Type: application/json"
  ]
  var payload = {
    "content": content,
    "message_reference": {
      "message_id": id
    }
  }
  var http_request = HTTPRequest.new()
  DiscordRequestHandler.add_child(http_request)
  http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
  http_request.request_completed.connect(func(_r, _c, _h, _b): http_request.queue_free())
