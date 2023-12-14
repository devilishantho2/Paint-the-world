extends CharacterBody2D

@export var move_speed = 250.0

@export var jump_height = 150
@export var jump_time_to_peak = 0.7
@export var jump_time_to_descent = 0.3
@export var coyote_time = 0.2

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
var can_jump = false
var is_walking = false
var slide_time = 0.2

func _physics_process(delta):
	velocity.y += get_gravity() * delta
	velocity.x = get_input_velocity() * move_speed
	$Label.set_text(str(int(velocity.x))+" "+str(int(velocity.y)))
	
	if is_on_floor():
		$AnimationTree.set("parameters/air_state/transition_request", "ground")
	
	jump(delta)
	move_and_slide()

func get_gravity():
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func jump(delta):
	if is_on_floor() and can_jump==false:
		can_jump = true
	elif can_jump == true and $CoyoteTimer.is_stopped():
		$CoyoteTimer.start(coyote_time)
	
	if Input.is_action_just_pressed("up") and can_jump:
		velocity.y = jump_velocity
		$AnimationTree.set("parameters/jump_state/transition_request", "jump")
		$AnimationTree.set("parameters/air_state/transition_request", "air")
	if Input.is_action_just_released("up") and velocity.y<-100:
		velocity.y = get_gravity() * delta * 0.8
		$AnimationTree.set("parameters/jump_state/transition_request", "fall")


func get_input_velocity() -> float:
	var horizontal := 0.0
	
	if Input.is_action_pressed("left"):
		horizontal -= 1.0
		is_walking = true
		$Sprite2D.flip_h = true
		$AnimationTree.set("parameters/move_state/transition_request", "walk")
	elif Input.is_action_pressed("right"):
		horizontal += 1.0
		is_walking = true
		$Sprite2D.flip_h = false
		$AnimationTree.set("parameters/move_state/transition_request", "walk")
		
	elif Input.is_action_just_released("left") || Input.is_action_just_released("right"):
		is_walking = false
		$AnimationTree.set("parameters/move_state/transition_request", "slide")
		$SlideTimer.start(slide_time)
		
	elif velocity.x == 0 :
		$AnimationTree.set("parameters/move_state/transition_request", "idle")
	
	if is_walking == false:
		if velocity.x<0:
			horizontal = -$SlideTimer.time_left*(1.0/slide_time)
		else:
			horizontal = $SlideTimer.time_left*(1.0/slide_time)
	
	return horizontal

func _on_coyote_timer_timeout():
	can_jump = false
