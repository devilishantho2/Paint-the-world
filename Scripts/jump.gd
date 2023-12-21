extends CharacterBody2D

@export var move_speed = 250.0

@export var jump_height = 300
@export var jump_time_to_peak = 0.7
@export var jump_time_to_descent = 0.3

#@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
#@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

var can_jump := false
var is_jumping = false

func jump_gravity(t):
	return (55/12-425/8*t+125/2*t*t)*jump_height
	
func jump_velocity(t):
	return -(113/48+55/12*t-425/16*t*t+125/6*t*t*t)*jump_height
	
func fall_velocity(t):
	return (187.403-2*432.985*t+3*445.036*t*t-4*172.234*t*t*t)*jump_height

func _physics_process(delta):
	
	velocity.y = get_y()
	velocity.x = get_input_velocity() * move_speed
	$Label.set_text(str(int(velocity.x))+" "+str(int(velocity.y)))	
	jump()
	if is_jumping and velocity.y == 0:
		$JumpTime.start(0.01)
		print("lol")
	move_and_slide()

func jump():
	if is_on_floor() and Input.is_action_just_pressed("space"):
		$JumpTime.start(jump_time_to_peak)
		is_jumping = true
		
func get_y():
	var y = 0

	if is_jumping == false:
		y = 100
	elif is_jumping == true and $JumpTime.time_left > 0:
		y = jump_velocity(jump_time_to_peak-$JumpTime.time_left)
	elif is_jumping == true and $FallTime.time_left > 0:
		y = fall_velocity($JumpTime.time_left)
	elif is_jumping == true and velocity.y == 0:
		$JumpTime.start(0.01)
		print("lol")
		
	return y
		
func get_input_velocity():
	var horizontal := 0.0

	if Input.is_action_pressed("right"):
		horizontal += 1.0
		$Sprite2D.flip_h = false
		$AnimationTree.set("parameters/move_state/transition_request", "walk")
		
	elif Input.is_action_pressed("left"):
		horizontal -= 1.0
		$Sprite2D.flip_h = true
		$AnimationTree.set("parameters/move_state/transition_request", "walk")

	elif velocity.x == 0 :
		$AnimationTree.set("parameters/move_state/transition_request", "idle")

	return horizontal


func _on_jump_time_timeout():
	$FallTime.start(jump_time_to_peak)
