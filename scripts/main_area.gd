extends Node2D


@onready var player_scene = preload("res://scenes/player.tscn")
var player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_player(Vector2(100, -100))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func spawn_player(spawn_position):
	if not player:
		player = player_scene.instantiate()
		player.set_global_position(spawn_position)
		add_child(player)
	
