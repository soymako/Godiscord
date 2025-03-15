class_name DiscordBot
extends Node
## The main entry point for Godiscord

## Discord bot token used for Godiscord.
## Create a bot at [url=https://discord.com/developers/applications]Discord Dev Portal[/url]
@export var token: String
## Used to register slash commands, discords requires a GUILD_ID to register commands automatically[br]
## for now, this will do the trick[br][br]
## Right Click on the server image and press [color=aqua][i]Copy Server ID[/i][/color] and paste it here


## prints to the console
@export var debug:bool = true;


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

var guilds: Array[DiscordGuild]

func debugPrint(message:String)->void:
  if debug:
    print_rich("[color=aqua]Godiscord🎮[/color]: %s" % message)
  pass

func _ready():
  _websocket = WebSocketPeer.new()
  _websocket.connect_to_url("wss://gateway.discord.gg/?v=9&encoding=json")
  heartbeat_timer.autostart = false
  heartbeat_timer.one_shot = false
  heartbeat_timer.timeout.connect(_heartbeat)

  self.bot_ready.connect(on_ready)

  if token.is_empty():
    push_error("TOKEN is empty. Cannot connect to Discord.")
  if token.length() < 50:
    push_error("TOKEN may not be valid.")




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

# delete this
func on_ready():
  # print("mi id: %s" % user.id)
  pass

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
    await get_guilds()
    debugPrint("Bot is ready")
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
    command_request.caller.mention = "<@%s>" % command_request.caller.id
    command_used.emit(command_request)

func get_guilds()->void:
  var url = "https://discord.com/api/v9/users/@me/guilds"
  var headers = [
    "Authorization: Bot %s" % token,
    "Content-Type: application/json"
  ]
  var http_req = HTTPRequest.new()
  DiscordRequestHandler.add_child(http_req)
  http_req.request_completed.connect(func(_r, _c, _h, _b): print("request completed"); http_req.queue_free())
  var error = http_req.request(url, headers, HTTPClient.METHOD_GET)

  if error == OK:
    var response = await http_req.request_completed

    var code = response[1]
    var body:PackedByteArray = response[3]

    if code == 200:
      var json:JSON = JSON.new()
      json.parse(body.get_string_from_utf8())
      for i:int in json.get_data().size():
        var obj:Dictionary = json.get_data()[i]
        var id:String = obj.get("id")
        if id:

          var guild:DiscordGuild = DiscordGuild.new()

          guild.name = obj.get("name") as String
          guild.id = obj.get("id") as String
          # obj.get("icon").get_class()
          var icon = obj.get("icon")
          if icon:
            guild.icon = obj.get("icon")
          guild.permissions = obj.get("permissions") as int
          var features:Array = obj.get("features")
          if features.size() > 0:
            for _feature:String in features:
              guild.features.append(_feature)
          guild.owner = obj.get("owner") as bool
          
          guilds.append(guild)
          print(obj)
          debugPrint("Added guild: %s" % id)

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
  for currentGuild:DiscordGuild in guilds:
    # if guild_id.is_empty():
      # push_error("guild_id is empty. If your command does not register, enable Developer Mode in Discord, copy the Server ID, and set it in the 'guild_id' field.");
    var url = "https://discord.com/api/v9/applications/%s/guilds/%s/commands" % [user.id, currentGuild.id]
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
    debugPrint("Registered command: %s on guild: %s" %[command_name, currentGuild])




  pass
  # return []

## message -> The message to send
## channel -> The channel to send the message to
## embed -> Optional field used to send a discord embed
func send_message(message:String, channel:DiscordChannel, embed:Dictionary = {})->void:
  if channel == null: return
  var url = "https://discord.com/api/v9/channels/%s/messages" % channel.id
  var headers = [
    "Authorization: Bot %s" % token,
    "Content-Type: application/json"
  ]
  var payload:Dictionary = {
    "content": message
  }
  if embed.size() > 0:
    payload["embeds"] = [embed]
  var http_req = HTTPRequest.new()
  DiscordRequestHandler.add_child(http_req)
  http_req.request_completed.connect(func(_r, _c, _h, _b): http_req.queue_free())
  http_req.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
  pass

func get_server_channels(guild:DiscordGuild)->Array[DiscordChannel]:

  if token.is_empty():
    push_error("TOKEN is empty. Cannot fetch channels.")
    return []

  var channels:Array[DiscordChannel]

  var url = "https://discord.com/api/v9/guilds/%s/channels" % guild.id
  var headers = [
      "Authorization: Bot %s" % token 
  ]
    
  var http_req = HTTPRequest.new()
  DiscordRequestHandler.add_child(http_req)
  http_req.request_completed.connect(func(_r, _c, _h, _b): http_req.queue_free())
  
  var error = http_req.request(url, headers, HTTPClient.METHOD_GET)
  if error == OK:
    var response:Array = await http_req.request_completed
    var result:int = response[0]
    var code:int = response[1]
    var receivedHeaders:PackedStringArray = response[2]
    var body:PackedByteArray = response[3]

    if code == 200:
      var json:JSON = JSON.new()
      var parse_error:int = json.parse(body.get_string_from_utf8())

      if parse_error == OK:
        var data:Array = json.get_data()
        for i:int in data.size():
          var obj:Dictionary = data[i]
          var parentID = obj.get("parent_id")
          if parentID != null:
            var channel:DiscordChannel = DiscordChannel.new()
            channel.id = obj.get("id")
            channel.type = obj.get("type")
            channel.name = obj.get("name")
            channel.nsfw = obj.get("nsfw")
            channel.rate_limit_per_user = obj.get("rate_limit_per_user")
            channels.append(channel)
  return channels

func get_channel_of_name(guild:DiscordGuild, name:String)->DiscordChannel:
  var channel:DiscordChannel
  var channels:Array[DiscordChannel] = await get_server_channels(guild)
  for _c:DiscordChannel in channels:
    if _c.name == name:
      channel = _c
  return channel

func get_channel_of_id(guild:DiscordGuild, id:int)->DiscordChannel:
  var channel:DiscordChannel
  var channels:Array[DiscordChannel] = await get_server_channels(guild)
  for _c:DiscordChannel in channels:
    if _c.id == id:
      channel = _c
  return channel

func get_guild_by_name(guild_name:String)->DiscordGuild:
  var guild:DiscordGuild
  for _g:DiscordGuild in guilds:
    if _g.name == guild_name:
      guild = _g
  return guild


# dunno why somebody would need this, but if someone does, here it is
func get_guild_by_id(id:String)->DiscordGuild:
  var guild:DiscordGuild
  for _g:DiscordGuild in guilds:
    if _g.id == id:
      guild = _g
  return guild
