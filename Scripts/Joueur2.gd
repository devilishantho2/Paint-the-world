extends CharacterBody2D

@export var move_speed = 250.0

@export var jump_height = 150
@export var jump_time_to_peak = 0.7
@export var jump_time_to_descent = 0.3
@export var coyote_time = 0.2

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

var can_jump := false
var can_dash := true
var is_walking := false
var is_dashing := false
var on_ladder := false
var is_climbing := false
var slide_time = 0.2

func _physics_process(delta):

	velocity.y += get_gravity() * delta*(1-int(is_dashing))
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
	
	if Input.is_action_pressed("up") and on_ladder:
		velocity.y = -200
		$AnimationTree.set("parameters/climb_state/transition_request", "climb")
	if Input.is_action_just_released("up"):
		$AnimationTree.set("parameters/climb_state/transition_request", "dont_climb")

	if Input.is_action_just_pressed("space") and can_jump:
		velocity.y = jump_velocity
		$AnimationTree.set("parameters/jump_state/transition_request", "jump")
		$AnimationTree.set("parameters/air_state/transition_request", "air")
	if Input.is_action_just_released("space") and velocity.y<-100:
		velocity.y = get_gravity() * delta * 0.8
		$AnimationTree.set("parameters/jump_state/transition_request", "fall")


func get_input_velocity() -> float:
	var horizontal := 0.0

	if is_climbing == false:
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

		if Input.is_action_pressed("a") and is_dashing == false and can_dash == true:
			$DashTimer.start(0.1)
			$DashWaitTimer.start(1)
			is_walking = true
			$AnimationTree.set("parameters/dash_state/transition_request", "dash")
			is_dashing = true
			can_dash = false

		elif Input.is_action_just_released("left") || Input.is_action_just_released("right"):
			is_walking = false
			$AnimationTree.set("parameters/move_state/transition_request", "slide")
			$SlideTimer.start(slide_time)
			
		elif velocity.x == 0 :
			$AnimationTree.set("parameters/move_state/transition_request", "idle")

		if is_walking == false:
			if velocity.x>0:
				horizontal = $SlideTimer.time_left*(1.0/slide_time)
			elif velocity.x<0: 
				horizontal = -$SlideTimer.time_left*(1.0/slide_time)

		if is_dashing:
			horizontal = 7.0*(1-2*int($Sprite2D.flip_h)) #-7 ou +7 selon orientation

	return horizontal

func _on_coyote_timer_timeout():
	can_jump = false

func _on_dash_timer_timeout():
	is_dashing = false
	$AnimationTree.set("parameters/dash_state/transition_request", "no_dash")

func _on_dash_wait_timer_timeout():
	can_dash = true

func _on_ladder_checker_body_entered(body):
	on_ladder = true

func _on_ladder_checker_body_exited(body):
	on_ladder = false
	$AnimationTree.set("parameters/climb_state/transition_request", "dont_climb")
