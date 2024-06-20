extends Node2D

@onready var log_scene   = preload("res://scenes/log.tscn")
@onready var t_log_scene = preload("res://scenes/tiny_log.tscn")
@onready var log_texture = load("res://assets/Environment/Trees/Log1.png")

var current_segments = 1

func create_log(segments):
	current_segments = segments
	
	# --- sprites ---
	for i in range(current_segments):
		var sprite = Sprite2D.new()
		sprite.texture = log_texture
		sprite.hframes = 4
		sprite.position = Vector2(8 + 16 * i, -8)
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		
		$sprites.add_child(sprite)
	
	# --- split collisions ---
	for i in range(current_segments - 1):
		var area = Area2D.new()
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		
		shape.size = Vector2(2, 2)
		
		collision.shape = shape
		area.position = Vector2(16 + 16 * i, -2)
		area.collision_mask = 0b00000000_00000000_00000000_00001000
		area.connect("area_entered", self.get_hit.bind(i))
		
		area.add_child(collision)
		$collisions.add_child(area)

func split(segment_pos):
	# --- left ---
	var left = log_scene.instantiate() if segment_pos + 1 > 1 else t_log_scene.instantiate()
	left.set_global_position(position)
	left.set_scale(scale)
	
	add_sibling(left) 
	if segment_pos + 1 > 1: left.create_log(segment_pos + 1)
	
	# --- right ---
	var right = log_scene.instantiate() if current_segments - segment_pos - 1 > 1 else t_log_scene.instantiate()
	right.set_global_position(Vector2(position.x + 16 * (segment_pos + 1), position.y))
	right.set_scale(scale)
	
	add_sibling(right) 
	if current_segments - segment_pos - 1 > 1: right.create_log(current_segments - segment_pos - 1)
	
	queue_free()

func pickup(_area):
	pass

func get_hit(area, segment_pos):
	if area.is_in_group("axe"): call_deferred("split", segment_pos)
