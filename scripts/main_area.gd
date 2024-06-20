extends Node2D
# https://www.washington.edu/uwired/outreach/cspn/Website/Classroom%20Materials/Curriculum%20Packets/High%20Lead%20Logging/IV.html

@onready var player_scene = preload("res://scenes/player.tscn")
var player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_player(Vector2(16, -32))

func spawn_player(spawn_position):
	if not player:
		player = player_scene.instantiate()
		player.set_global_position(spawn_position)
		add_child(player)
