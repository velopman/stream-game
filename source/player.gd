class_name Player extends KinematicBody2D

onready var sprite: Sprite = $sprite
onready var username: Label = $username

var __color: Color = Color.white
var __move: Vector2 = Vector2.ZERO
var __rotation_current: float = 0.0
var __rotation_target: float = 0.0
var __username: String = ""


func _ready() -> void: 
	self.username.text = self.__username
	self.change_color(self.__color)


func _process(delta: float) -> void:
	if self.__rotation_current != self.__rotation_target:
		self.__rotation_current = self.__rotation_target
#		var differance = self.__rotation_current - self.__rotation_target
#		var difference_absolute = abs(differance)
#		var difference_sign = sign(differance)
#		var difference_change = difference_absolute - 45.0 * delta
#		var difference_clamp = clamp(difference_change, 0.0, difference_absolute)
#		self.__rotation_current += difference_sign * difference_change
		# c: 180 t: 160 
		# -20 
		# 
	var speed = Globals.movement_speed * delta
	var movement =  Vector2.UP.rotated(self.__rotation_current) * speed
	var collision = self.move_and_collide(movement)
	if collision: 
		var collision_angle = Vector2.UP.angle_to(collision.normal)
		self.__rotation_current = collision_angle
		self.__rotation_target = collision_angle

	
func initialize(username: String, color: Color) -> void:
	self.__username = username
	self.__color = color


func change_collision(collide: bool) -> void:
	self.collision_mask = 1


func change_color(color: Color) -> void:
	self.__color = color
	
	self.username.modulate = self.__color
	self.modulate = self.__color


func change_move(rotation: float, override: bool = false) -> void:
	if override: 
		self.__rotation_current = rotation
	self.__rotation_target = rotation
	
