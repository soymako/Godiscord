class_name DiscordBot
extends Node

const BASE_URL = "https://discordapp.com/api"
@export var token = ""
@export var http_request: HTTPRequest

func _ready():
	http_request.request_completed.connect(_on_request_completed)

func set_token(bot_token: String):
	token = bot_token

func send_message(channel_id: String, content: String):
	var headers = [
		"Authorization: Bot " + token,
		"Content-Type: application/json"
	]
	#var body = JSON.print({"content": content})
	http_request.request(BASE_URL + "/channels/" + channel_id + "/messages", headers, HTTPClient.METHOD_POST, content)

func _on_request_completed(result, _response_code, _headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	if json.error == OK:
		print("Response: ", json.result)
	else:
		print("Error parsing JSON")
