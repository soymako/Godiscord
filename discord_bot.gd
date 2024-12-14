extends Node

var token = OS.get_environment("DISCORD_BOT_TOKEN")

var websocket: WebSocketPeer

func _ready():
	websocket = WebSocketPeer.new()
	websocket.connect_to_url("wss://gateway.discord.gg/?v=9&encoding=json")

func _process(_delta):
	websocket.poll()
	var state = websocket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while websocket.get_available_packet_count():
			var data = websocket.get_packet().get_string_from_utf8()
			print("Packet: ", data)
			var json = JSON.parse_string(data)
			if json["op"] == 10:  # Hello
				var heartbeat_interval = json.d.heartbeat_interval / 1000.0
				send_identify()
				start_heartbeat(heartbeat_interval)
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = websocket.get_close_code()
		var reason = websocket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.

func send_identify():
	var payload = {
		"op": 2,
		"d": {
			"token": token,
			"intents": 513,
			"properties": {
				"$os": OS.get_name(),
				"$browser": "godot",
				"$device": "godot"
			}
		}
	}
	websocket.put_packet(JSON.stringify(payload).to_utf8_buffer())

func start_heartbeat(interval: float):
	await get_tree().create_timer(interval).timeout
	websocket.put_packet(JSON.stringify({"op": 1, "d": null}).to_utf8_buffer())
	start_heartbeat(interval)
