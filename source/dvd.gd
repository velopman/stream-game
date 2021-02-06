extends KinematicBody2D

var __direction = Vector2(1.0, 1.0).normalized()
var __next_use = 0


func _ready() -> void:
	Event.connect("show_dvd", self, "__show_dvd")


func _physics_process(delta: float) -> void:
	var collision = self.move_and_collide(self.__direction * 30.0 * delta)
	if collision: 
		self.__direction = self.__direction.bounce(collision.normal)


func __show_dvd() -> void:
	if self.__next_use <= Time.elapsed_time: 
		self.visible = !self.visible
		
		self.__next_use = Time.elapsed_time + 10.0 
