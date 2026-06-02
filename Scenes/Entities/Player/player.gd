extends CharacterBody3D

#jump
@export var jump_height : float = 2.25
@export var jump_time_to_peak : float = 0.4
@export var jump_time_to_descent : float = 0.3

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

@export var base_speed := 4.0
@export var run_speed := 6.0

@onready var camera = $CameraController/Camera3D
@onready var skin = $GodetteSkin

var movement_input := Vector2.ZERO
var defend := false:
	set(value):
		if not defend and value:
			skin._defend(true)
		if defend and not value:
			skin._defend(false)
		defend = value

func _physics_process(delta: float) -> void:
	_move_logic(delta)
	_jump_logic(delta)
	_ability_logic()
	move_and_slide()

func _move_logic(delta: float) -> void:
	movement_input = Input.get_vector("left", "right", "forward", "backward").rotated(-camera.global_rotation.y)
	var vel_2d = Vector2(velocity.x, velocity.z)
	var is_running := Input.is_action_pressed("run")
	
	if movement_input != Vector2.ZERO:
		var speed = run_speed if is_running else base_speed
		vel_2d += movement_input * speed * delta
		vel_2d = vel_2d.limit_length(speed)
		velocity.x = vel_2d.x
		velocity.z = vel_2d.y
		skin._set_move_state("Running")
		var target_angle = -movement_input.angle() + PI/2
		skin.rotation.y = rotate_toward(skin.rotation.y, target_angle, 6.0 * delta)
	else:
		vel_2d = vel_2d.move_toward(Vector2.ZERO, base_speed * 4.0 * delta)
		velocity.x = vel_2d.x
		velocity.z = vel_2d.y
		skin._set_move_state("Idle")

func _jump_logic(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_velocity
	elif not is_on_floor():
		skin._set_move_state("Jump")
	var gravity = jump_gravity if velocity.y > 0.0 else fall_gravity
	velocity.y -= gravity * delta
	
func _ability_logic() -> void:
	if Input.is_action_just_pressed("ability"):
		skin._attack()
	
	defend = Input.is_action_pressed("block")
