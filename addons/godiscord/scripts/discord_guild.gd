# this got out of hand...

class_name DiscordGuild
extends DiscordResource

var id:String
var name:String


var icon:String
var banner:String
var permissions:int
var features:Array

var channels:Array[DiscordChannel]


func _init(id:String = "-1", name:String = "", icon:String = "", banner:String = "", features:Array = []) -> void:
  self.id = id
  self.name = name
  self.icon = icon if icon != null else ""
  self.banner = banner if banner != null else ""
  self.features = features

static func fromID(id:String, token:String)->DiscordGuild:
  var url = "https://discord.com/api/v9/guilds/%s" %id
  var headers = [
    "Authorization: Bot %s" % token,
    "Content-Type: application/json"
  ]
  var http_req = HTTPRequest.new()
  DiscordRequestHandler.add_child(http_req)
  http_req.request_completed.connect(func(_r, _c, _h, _b): http_req.queue_free())
  var error = http_req.request(url, headers, HTTPClient.METHOD_GET)
  if error == OK:
    var response = await http_req.request_completed
    var code = response[1]
    var body:PackedByteArray = response[3]
    if code != 200: push_error("request failed"); return null
    
    var json:JSON = JSON.new()
    json.parse(body.get_string_from_utf8())
    
    var data:Dictionary = json.data
    #print("data: ", json.stringify(data))
    
    
    var guild:DiscordGuild = DiscordGuild.new(
      data["id"],
      data["name"],
      data["icon"] if data["icon"] != null else "",
      data["banner"] if data["banner"] != null else "",
      data["features"]
    )
    
    #if data.has("icon"):
      ##var icon = data["icon"]
      ##print("icono: ", icon)
      #guild.icon = data["icon"] if data["icon"] != null else ""
    #if data.has("banner"):
      ##guild.banner = data["banner"]
      #pass
    
    
    return guild
    
  return null

# just... ignore this... I just think it would be better with autocomplete :P

# I gave up on that, if you want to continue with the idea of autocomplete, then go ahead and uncomment this

# enum Features{
#   ANIMATED_ICON,
#   BANNER,
#   COMMERCE,
#   COMMUNITY,
#   DISCOVERABLE,
#   ENABLED_DISCOVERABLE_BEFORE,
#   FORCE_RELAY,
#   RELAY_ENABLED,
#   INVITE_SPLASH,
#   MEMBER_VERIFICATION_GATE,
#   MORE_EMOJI,
#   NEWS,
#   PARTNERED,
#   VERIFIED,
#   VANITY_URL,
#   VIP_REGIONS,
#   WELCOME_SCREEN_ENABLED,
#   DISCOVERY,DISABLED,
#   PREVIEW_ENABLED,
#   MORE_STICKERS,
#   MONETIZATION_ENABLED,
#   TICKETING_ENABLED,
#   HUB,
#   LINKED_TO_HUB,
#   HAS_DIRECTORY_ENTRY,
#   THREADS_ENABLED,
#   THREADS_ENABLED_TESTING,
#   NEW_THREAD_PERSMISSIONS,
#   THREE_DAY_THREAD_ARCHIVE,
#   SEVEN_DAY_THREAD_ARCHIVE,
#   THREAD_DEFAULT_AUTO_ARCHIVE_DURATION,
#   ROLE_ICONS,
#   INTERNAL_EMPLOYEE_ONLY,
#   PREMIUM_TIER_3_OVERRIDE,
#   FEATURABLE,
#   MEMBER_PROFILES,
#   AUTOMOD_TRIGGER_KEYWORD_FILTER,
#   AUTOMOD_TRIGGER_SPAM_LINK_FILTER,
#   GUILD_AUTOMOD_DEFAULT_LIST,
#   TEXT_IN_VOICE_ENABLED,

#   # unreleased features

#   ROLE_SUBSCRIPTIONS_ENABLED,
#   ROLE_SUBSCRIPTIONS_ENABLED_FOR_PURCHASE,
#   ANIMATED_BANNER,
#   TEXT_IN_STAGE_ENABLED,
#   GUILD_ROLE_SUBSCRIPTIONS,
#   THREADS_ONLY_CHANNEL,
#   BOT_DEVELOPER_EARLY_ACCES,
#   MEMBER_VERIFICATION_MANUAL_APPROVAL,
#   GUILD_COMMUNICATION_DISABLED_GUILDS,
#   SOUNDBOARD,
#   GUILD_ROLE_SUBSCRIPTIONS_TRIALS,
#   GUILD_HOME_OVERRIDE,
#   GUILD_HOME_TEST,
#   VOICE_CHANNEL_EFFECTS,
#   VOICE_IN_THREADS,
#   ACTIVITIES_INTERNAL_DEV,
#   ACTIVITIES_EMPLOYEE,
#   ACTIVITIES_ALPHA,
#   COMMUNITY_EXP_LARGE_UNGATED,
#   COMMUNITY_EXP_LARGE_GATED,
#   DEVELOPER_SUPPORT_SERVER,

#   # deprecated features

#   MEMBER_LIST_DISABLED,
#   PUBLIC,
#   PUBLIC_DISABLED,
#   LURKABLE,
#   CHANNEL_BANNER
  
# }
