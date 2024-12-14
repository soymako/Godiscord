class_name DiscordChannel
extends Resource

var id: int
var token: String



#func send_message(content: String):
	#var url = "https://discord.com/api/v9/channels/%s/messages" % id
	#var headers = [
		#"Authorization: Bot %s" % token,
		#"Content-Type: application/json"
	#]
	#var payload = {
		#"content": content
	#}
	#var http_request = HTTPRequest.new()
	#DiscordRequestHandler.add_child(http_request)
	#http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
	#http_request.request_completed.connect(func(_r, _c, _h, _b): http_request.queue_free())
