# Gateway Opcodes 
# Reference: https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-opcodes

class_name DiscordOpcodes
extends Resource

const DISPATCH: int = 0
#Receive	An event was dispatched.

const HEARTBEAT: int = 1
#Send/Receive	Fired periodically by the client to keep the connection alive.

const IDENTIFY: int = 2
#Send	Starts a new session during the initial handshake.

const PRESENCE_UPDATE: int = 3
#Send	Update the client's presence.

const VOICE_STATE_UPDATE: int = 4
#Send	Used to join/leave or move between voice channels.

const RESUME: int = 6
#Send	Resume a previous session that was disconnected.

const RECONNECT: int = 7
#Receive	You should attempt to reconnect and resume immediately.

const REQUEST_GUILD_MEMBERS: int = 8
#Send	Request information about offline guild members in a large guild.

const INVALID_SESSION: int = 9
#Receive	The session has been invalidated. You should reconnect and identify/resume accordingly.

const HELLO: int = 10
#Receive	Sent immediately after connecting, contains the heartbeat_interval to use.

const HEARTBEAT_ACK: int = 11
#Receive	Sent in response to receiving a heartbeat to acknowledge that it has been received.

const REQUEST_SOUNDBOARD_SOUNDS: int = 31
#Send	Request information about soundboard sounds in a set of guilds.
