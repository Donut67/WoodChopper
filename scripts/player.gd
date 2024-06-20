extends CharacterBody2D


@onready var animation_tree   = $AnimationTree
@onready var tool_collision_1 = $Sprite2D/ToolEnd/SideCollision
@onready var tool_collision_2 = $Area2D/CollisionShape2D
#@onready var tool_collision_2 = $Sprite2D/Area2D/SideCollision

const SPEED = 110.0
const JUMP_VELOCITY = -280.0

var nearest_objects = []
var interactable_objects = []
var nearest_stations = []

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 1470 #ProjectSettings.get_setting("physics/2d/default_gravity")

var is_jumping = false
var has_landed = false
var can_attack = true
var can_move   = true
var over_head  = false

var nearest_object  = null
var picked_object = null

func _physics_process(delta):
	if not is_on_floor(): velocity.y += gravity * delta
	
	if can_move: handle_movement()
	
	if is_on_floor():
		if Input.is_action_just_pressed("INTERACT"): 
			if nearest_stations.size() > 0 && nearest_stations[0].is_in_group("workbech"): pass
			elif picked_object != null: place_object()
			elif picked_object == null: pickup()
		elif Input.is_action_just_pressed("ACTION") and can_attack: attack()

func set_state(state : String):
	animation_tree["parameters/conditions/walk"] = false
	animation_tree["parameters/conditions/idle"] = false
	animation_tree["parameters/conditions/is_jumping"] = false
	animation_tree["parameters/conditions/has_landed"] = false
	animation_tree["parameters/conditions/is_falling"] = false
	animation_tree["parameters/conditions/side_hit"] = false
	animation_tree["parameters/conditions/over_head"] = false
	
	animation_tree["parameters/conditions/" + state] = true

func handle_movement():
	has_landed = animation_tree["parameters/conditions/is_falling"] and is_on_floor()
	
	# Handle jump.
	if Input.is_action_just_pressed("JUMP") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("LEFT", "RIGHT")
	
	if direction: 
		velocity.x = direction * SPEED
		$Sprite2D.flip_h = direction < 0
		
		var x_pos_1 = tool_collision_1.position.x
		if direction < 0: tool_collision_1.position.x = -1 * abs(x_pos_1)
		else: tool_collision_1.position.x = abs(x_pos_1)
		
		var x_pos_2 = tool_collision_2.position.x
		if direction < 0: tool_collision_2.position.x = -1 * abs(x_pos_2)
		else: tool_collision_2.position.x = abs(x_pos_2)
	else: velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if has_landed: set_state("has_landed")
	elif velocity == Vector2.ZERO: set_state("idle")
	elif velocity.y > 0:  set_state("is_falling")
	elif velocity.y != 0: set_state("is_jumping")
	elif velocity.x != 0: set_state("walk")
	
	if velocity != Vector2.ZERO: 
		nearest_objects.sort_custom(sort_by_distance)
		
		over_head = nearest_objects.size() > 0 and nearest_objects[0].is_in_group("log")
	
	update_highlight(interactable_objects)
	#update_highlight(nearest_stations)
	move_and_slide()

func update_highlight(list):
	if list.size() == 0: return
	
	list.sort_custom(sort_by_distance)
	var nearest_node = list[0]
	
	for node in list:
		if node: node.highlight(node == nearest_node)

func sort_by_distance(a, b):
	var first  = a.position + a.get_child(0).get_shape().size / 2
	var second = b.position + b.get_child(0).get_shape().size / 2
	
	return position.distance_to(first) < position.distance_to(second)

func place_object():
	if nearest_stations.size() > 0: nearest_stations[0].place(picked_object)
	else: drop()

func pickup():
	if interactable_objects.size() > 0:
		picked_object = interactable_objects[0]
		picked_object.position = Vector2(-8, 0)
		picked_object.get_parent().remove_child(picked_object)
		$Sprite2D.add_child(picked_object)
		$InputArea/CollisionShape2D.disabled = true

func drop():
	if picked_object:
		picked_object.get_parent().remove_child(picked_object)
		add_sibling(picked_object)
		picked_object.position = Vector2(position.x - 8, position.y)
		picked_object = null
		
		$InputArea/CollisionShape2D.disabled = false

func attack():
	if over_head: set_state("over_head")
	else: set_state("side_hit")
	
	$AttackTimer.start()
	$Timer.start()
	
	can_attack = false
	can_move = false

func _on_attack_timer_timeout():
	can_attack = true
	can_move = true
	tool_collision_1.disabled = true

func _on_timer_timeout():
	tool_collision_1.disabled = false

func _on_area_2d_area_entered(area):
	if not nearest_objects.has(area): nearest_objects.push_back(area)

func _on_area_2d_area_exited(area):
	if nearest_objects.has(area): nearest_objects.erase(area)

func _on_input_area_area_entered(area):
	if area.is_in_group("pickable") and not interactable_objects.has(area): 
		interactable_objects.push_back(area)

func _on_input_area_area_exited(area):
	if area.is_in_group("pickable") and interactable_objects.has(area): 
		area.highlight(false)
		interactable_objects.erase(area)

func _on_interactable_area_entered(area):
	if area.is_in_group("station") and not nearest_stations.has(area): 
		nearest_stations.push_back(area)

func _on_interactable_area_exited(area):
	if area.is_in_group("station") and nearest_stations.has(area): 
		area.highlight(false)
		nearest_stations.erase(area)

func _on_tool_end_area_entered(area):
	if nearest_objects.size() > 0 and area == nearest_objects[0]:
		if area.is_in_group("can_be_hit"): area.get_hit(position)
		#else: area.get_hit(position)
