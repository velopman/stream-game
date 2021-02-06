extends Node

const player = preload("res://source/player.tscn")

onready var announcement = $announcement

var __accepting_join: bool = true
var __players: Dictionary = {
	# key: username
	# value: reference to player instance
}


func _ready() -> void:
	Event.connect("player_joined", self, "__player_joined")
	Event.connect("player_moved", self, "__player_moved")
	
	
	var channel = SettingsManager.get_setting("twitch/channel", "")
	var oauth_token = SettingsManager.get_setting("twitch/oauth_token", "")
	
	var instance = TwitchInput.new(channel, oauth_token)
	self.call_deferred("add_child", instance)


func _process(delta: float) -> void:
	if Globals.movement_speed != 0.0:
		Globals.movement_speed += delta


func __announce(message: String) -> void:
	self.announcement.text = message


func __end_game() -> void:
	Globals.movement_speed = 0.0
	
	var player = self.__players.values()[0]
	
	TaskManager.add_queue(
		"end_1",
		Task.Lerp.new(player.position, Vector2(640.0, 360.0), 0.5, funcref(player, "set_position"))
	)

	TaskManager.add_queue(
		"end_2",
		Task.Lerp.new(player.scale, Vector2(5.0, 5.0), 0.5, funcref(player, "set_scale"))
	)

func __player_joined(username: String, color: Color) -> void:
	if !self.__accepting_join:
		return
	
	if username in self.__players:
		self.__players[username].change_color(color)
	else: 
		var instance = self.player.instance()
		instance.initialize(username, color)
		instance.position = Vector2(640.0, 360.0) + Vector2.UP.rotated(randf() * TAU) * randf() * 200.0
		
		self.__players[username] = instance
		
		self.call_deferred("add_child", instance)
	

	if __players.size() == 2:
		self.__start_game()


func __player_moved(username: String, rotation: float) -> void:
	if !username in self.__players:
		return
	
	self.__players[username].change_move(rotation)


func __start_game() -> void:
	for i in range(10, 0, -1): 
		self.__announce("Type !join to join\nStarting game in %d seconds!" % i)

		yield(self.get_tree().create_timer(1.0), "timeout")
	
	self.__accepting_join = false
	self.__announce("STAY IN THE CIRCLE!")
	
	for player in self.__players:
		player = self.__players[player]
		player.position = Vector2(640.0, 360.0)
		player.change_move(randf() * TAU, true)
	
	Globals.movement_speed = 5.0
	
	yield(self.get_tree().create_timer(3.0), "timeout")
	
	for player in self.__players:
		self.__players[player].change_collision(true)


func _on_area_body_exited(body):
	var username = body.__username 
	if !username in self.__players:
		return
	
	self.__announce("%s left the circle!" % username)
	self.__players.erase(username)
	body.call_deferred("queue_free")
	
	if self.__players.size() == 1:
		self.__end_game()
	
