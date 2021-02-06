class_name TwitchInput extends Gift

var channel: String = ""
var oauth_token: String = ""


func _init(channel, oauth_token) -> void:
	self.channel = channel
	self.oauth_token = oauth_token


func _ready() -> void:
	self.connect("cmd_no_permission", self, "no_permission")
	self.connect_to_twitch()
	yield(self, "twitch_connected")

	self.authenticate_oauth("username", self.oauth_token)
	if(yield(self, "login_attempt") == false):
	  print("Invalid username or token.")
	  return
	self.join_channel(self.channel)

	self.add_command("join", self, "__join", 1, 1)
	self.add_alias("join", "j")
	self.add_alias("join", "color")
	self.add_alias("join", "colour")
	self.add_alias("join", "c")
	
	self.add_command("move", self, "__move", 1, 1)
	self.add_alias("move", "m")
	
	self.add_command("dvd", self, "__dvd")

	self.chat("Starting game of <insert_name>!")
	self.chat("Type !join to join")


func __dvd(cmd_info: CommandInfo) -> void:
	Event.emit_signal("show_dvd")

func __join(cmd_info: CommandInfo, arg_ary : PoolStringArray) -> void:
	var username = cmd_info.sender_data.tags["display-name"]
	var color = Color(arg_ary[0])
	
	Event.emit_signal("player_joined", username, color)


func __move(cmd_info: CommandInfo, arg_ary : PoolStringArray) -> void:
	var username = cmd_info.sender_data.tags["display-name"]
	var rotation = deg2rad(int(arg_ary[0]))
	
	Event.emit_signal("player_moved", username, rotation)


