extends Area2D

@onready var log_scene = preload("res://scenes/log.tscn")
var hit_points = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func clean():
	var log_i = log_scene.instantiate()
	log_i.set_global_position(position)
	log_i.set_scale(scale)
	
	add_sibling(log_i) 
	log_i.create_log(5)
	
	queue_free()

func get_hit(_position):
	hit_points -= 1
	$AnimationPlayer.play("shake")
	if hit_points == 0: call_deferred("clean")
