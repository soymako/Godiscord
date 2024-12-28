class_name DiscordBot
extends Node
## The main entry point for Godiscord

## Discord bot token used for Godiscord.
## Create a bot at [url=https://discord.com/developers/applications]Discord Dev Portal[/url]
@export var token: String
@onready var heartbeat_timer: Timer = Timer.new()

## Emitted when a message is recieved.
signal message_recieved(message: DiscordMessage)
## Emitted when a slash command is used.
signal command_used(command: DiscordCommandRequest)
## Emitted when the bot is ready.
signal bot_ready()

var _websocket: WebSocketPeer
## The account of the bot. Use after [signal DiscordBot.bot_ready]
var user: DiscordUser

var intents: int = DiscordIntents.DEFAULT
## For Gateway intents, guilds, messaging, DM
var sequence_number: int
## For resuming sessions and heartbeating

func _ready():
	_websocket = WebSocketPeer.new()
	_websocket.connect_to_url("wss://gateway.discord.gg/?v=9&encoding=json")
	heartbeat_timer.autostart = false
	heartbeat_timer.one_shot = false
	heartbeat_timer.timeout.connect(_heartbeat)
	add_child(heartbeat_timer)

func _process(_delta):
	_websocket.poll()
	var state = _websocket.get_ready_state()
	
	if state == WebSocketPeer.STATE_OPEN:
		while _websocket.get_available_packet_count():
			var data = _websocket.get_packet().get_string_from_utf8()
			var json = JSON.parse_string(data)
			var Opcode: int = json["op"]
			
			if Opcode == DiscordOpcodes.DISPATCH:
				_event_handler(json)
				continue
			
			if Opcode == DiscordOpcodes.HELLO:
				var heartbeat_interval: float = json["d"]["heartbeat_interval"] / 1000.0
				var jitter: float = randf() # 
				heartbeat_timer.wait_time = heartbeat_interval
				_send_identify()
				_start_heartbeat(heartbeat_interval * jitter)
				
			# TODO: add handlers for other opcodes
		
	elif state == WebSocketPeer.STATE_CLOSING:
		pass
		
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = _websocket.get_close_code()
		var reason = _websocket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false)

func _send_identify():
	var payload = {
		"op": 2,
		"d": {
			"token": token,
			"intents": intents,
			"properties": {
				"$os": OS.get_name(),
				"$browser": "godot",
				"$device": "godot"
			}
		}
	}
	_websocket.put_packet(JSON.stringify(payload).to_utf8_buffer())

func _event_handler(payload: Dictionary):
	# Reference https://discord.com/developers/docs/events/gateway-events#payload-structure
	var event: String = payload["t"]
	var sequence: int = payload["s"]
	var data: Dictionary = payload["d"]
	
	sequence_number = sequence
	if event == "READY":
		user = DiscordUser.new()
		user.id = int(data["user"]["id"])
		user.name = data["user"]["username"]
		bot_ready.emit()
		
	elif event == "MESSAGE_CREATE":
		var message = DiscordMessage.new()
		message.token = token
		message.content = data["content"]
		message.author = DiscordUser.new()
		message.author.id = int(data["author"]["id"])
		# For some reason global_name returns null here
		# ^- From kruz: maybe it is an intent?  I see my user when
		# printing the global_name, but I'm using more intents
		# ^- Shuflduf: Im not sure what intents youre using, so im 
		# safeguard this a bit
		if data["author"]["global_name"] != null:
			message.author.global_name = data["author"]["global_name"]
		message.author.name = data["author"]["username"]
		message.channel = DiscordChannel.new()
		message.channel.token = token
		message.channel.id = int(data["channel_id"])
		message.id = int(data["id"])

		message_recieved.emit(message)
		
	elif event == "INTERACTION_CREATE":
		var options = {}

		if data["data"].has("options"):
			for i in data["data"]["options"]:
				options[i["name"]] = i["value"]

		var command_request = DiscordCommandRequest.new()
		command_request.options = options
		command_request.token = token
		command_request.interaction = data
		command_request.name = data["data"]["name"]
		command_request.caller = DiscordUser.new()
		command_request.caller.id = data["member"]["user"]["id"]
		command_request.caller.global_name = data["member"]["user"]["global_name"]
		command_request.caller.name = data["member"]["user"]["username"]
		command_used.emit(command_request)
		
func _heartbeat():
	# Reference https://discord.com/developers/docs/events/gateway#sending-heartbeats
	var data: Dictionary = {"op": 1, "d": sequence_number or null}
	_websocket.put_packet(JSON.stringify(data).to_utf8_buffer())

func _start_heartbeat(interval: float):
	await get_tree().create_timer(interval).timeout
	_heartbeat()
	heartbeat_timer.start()

## Register a slash command to the bot.
## To handle the usage of commands, please read [DiscordCommandRequest].[br]
## [b]Example:[/b]
## [codeblock]
## func _on_discord_bot_bot_ready() -> void:
##     discord_bot.register_slash_command("hello", "Says hello")
## [/codeblock]
## You can also register a list of slash command with options from
## [url=https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-option-structure]the docs[/url]:
## [codeblock]
## func _on_discord_bot_bot_ready() -> void:
##     var options = [{
##         "name": "pizza",
##         "description": "What's your favourite pizza flavour?",
##         "type": 3,
##         "required": false,
##     }]
##     discord_bot.register_slash_command("bye", "Says goodbye", options)
## [/codeblock]
func register_slash_command(command_name: String, description: String, options: Array = []):
	var url = "https://discord.com/api/v9/applications/%s/commands" % user.id
	var headers = [
		"Authorization: Bot %s" % token,
		"Content-Type: application/json"
	]
	var payload = {
		"name": command_name,
		"description": description,
		"options": options
	}
	var http_req = HTTPRequest.new()
	DiscordRequestHandler.add_child(http_req)
	http_req.request_completed.connect(func(_r, _c, _h, _b): http_req.queue_free())
	http_req.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
