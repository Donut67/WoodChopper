extends CharacterBody2D


@onready var animation_tree = $AnimationTree

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 1470 #ProjectSettings.get_setting("physics/2d/default_gravity")

var is_jumping   = false
var has_landed   = false
var can_attack   = true
var is_attacking = false


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if not is_attacking: handle_movement()
	
	if is_on_floor():
		if Input.is_action_just_pressed("INTERACT"): interact()
		elif Input.is_action_just_pressed("ACTION") and can_attack: attack()


func set_state(state : String):
	animation_tree["parameters/conditions/walk"] = false
	animation_tree["parameters/conditions/idle"] = false
	animation_tree["parameters/conditions/is_jumping"] = false
	animation_tree["parameters/conditions/has_landed"] = false
	animation_tree["parameters/conditions/is_falling"] = false
	animation_tree["parameters/conditions/side_hit"] = false
	#animation_tree["parameters/conditions/is_falling"] = false
	
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
	else: velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if has_landed: set_state("has_landed")
	elif velocity == Vector2.ZERO: set_state("idle")
	elif velocity.y > 0:  set_state("is_falling")
	elif velocity.y != 0: set_state("is_jumping")
	elif velocity.x != 0: set_state("walk")
	
	move_and_slide()


func interact():
	pass


func attack():
	set_state("side_hit")
	$AttackTimer.start()
	can_attack = false
	is_attacking = true


func _on_attack_timer_timeout():
	can_attack = true
	is_attacking = false


























