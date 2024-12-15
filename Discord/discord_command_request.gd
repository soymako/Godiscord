class_name DiscordCommandRequest
extends DiscordResource

var interaction: Dictionary
var name: String
var options: Dictionary
var caller: DiscordUser

func reply(content: String):
	var file = FileAccess.open("test.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(interaction))
	var url = "https://discord.com/api/v9/interactions/%s/%s/callback" % [interaction["id"], interaction["token"]]
	var headers = [
		"Authorization: Bot %s" % token,
		"Content-Type: application/json"
	]
	var payload = {
		"type": 4,
		"data": {
			"content": content
		}
	}
	var http_req = HTTPRequest.new()
	DiscordRequestHandler.add_child(http_req)
	http_req.request_completed.connect(func(_r, _c, _h, _b): http_req.queue_free())
	http_req.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
