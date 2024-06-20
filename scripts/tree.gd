extends Area2D

@onready var fallen_tree_scene = preload("res://scenes/fallen_tree.tscn")
@onready var stump_scene       = preload("res://scenes/stump.tscn")
var hit_points = 1
var player_position

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.frame = randi() % $Sprite2D.hframes

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if hit_points <= 0: fall((position - player_position).normalized().x)

func get_hit(_position):
	hit_points -= 1
	$AnimationPlayer.play("shake")
	player_position = _position

func fall(direction):
	var fallen_tree = fallen_tree_scene.instantiate()
	add_sibling(fallen_tree)
	fallen_tree.set_global_position(Vector2(position.x + 8 * direction, position.y))
	fallen_tree.set_scale(Vector2(direction, 1))
	
	var stump = stump_scene.instantiate()
	add_sibling(stump)
	stump.set_global_position(position)
	
	queue_free()
