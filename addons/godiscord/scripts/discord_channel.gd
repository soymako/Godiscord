class_name DiscordChannel
extends DiscordResource
## A Discord channel

## ID of the channel
var id: int

## Send a message to the channel. [br]
## [b]Example:[/b]
## [codeblock]
## func _on_discord_bot_message_recieved(message: DiscordMessage) -> void:
##     if message.author.id != discord_bot.user.id:
##         message.channel.send_message("You said: " + message.content)
## [/codeblock]
func send_message(content: String):
    var url = "https://discord.com/api/v9/channels/%s/messages" % id
    var headers = [
        "Authorization: Bot %s" % token,
        "Content-Type: application/json"
    ]
    var payload = {
        "content": content
    }
    var http_request = HTTPRequest.new()
    DiscordRequestHandler.add_child(http_request)
    http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
    http_request.request_completed.connect(func(_r, _c, _h, _b): http_request.queue_free())
