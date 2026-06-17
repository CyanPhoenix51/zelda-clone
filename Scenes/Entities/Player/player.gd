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
@export var defend_speed := 2.0
var speed_modifier := 1.0

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
var weapon_active := false

func _physics_process(delta: float) -> void:
	_move_logic(delta)
	_jump_logic(delta)
	_ability_logic()
	move_and_slide()
	if Input.is_action_just_pressed("ui_accept"):
		_hit()

func _move_logic(delta: float) -> void:
	movement_input = Input.get_vector("left", "right", "forward", "backward").rotated(-camera.global_rotation.y)
	var vel_2d = Vector2(velocity.x, velocity.z)
	var is_running := Input.is_action_pressed("run")
	
	if movement_input != Vector2.ZERO:
		var speed = run_speed if is_running else base_speed
		speed = defend_speed if defend else speed
		vel_2d += movement_input * speed * delta * 8.0
		vel_2d = vel_2d.limit_length(speed) * speed_modifier
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
		_do_squash_and_stretch(1.2, 0.15)
	elif not is_on_floor():
		skin._set_move_state("Jump")
	var gravity = jump_gravity if velocity.y > 0.0 else fall_gravity
	velocity.y -= gravity * delta
	
func _ability_logic() -> void:
	# actual attack
	if Input.is_action_just_pressed("ability"):
		if weapon_active:
			skin._attack()
		else:
			skin._cast_spell()
			_stop_movement(0.3, 0.8)
	
	# defend
	defend = Input.is_action_pressed("block")
	
	# swtich weapon/magic
	if Input.is_action_just_pressed('switch weapon') and not skin.attacking:
		weapon_active = not weapon_active
		skin._switch_weapon(weapon_active)
		_do_squash_and_stretch(1.2, 0.15)
	
func _stop_movement(start_duration: float, end_duration: float):
	var tween = create_tween()
	tween.tween_property(self, "speed_modifier", 0.0, start_duration)
	tween.tween_property(self, "speed_modifier", 1.0, end_duration)
	
func _hit():
	skin._hit()
	_stop_movement(0.3, 0.3)
	
func _do_squash_and_stretch(value: float, duration: float = 0.1):
	var tween = create_tween()
	tween.tween_property(skin, "squash_and_stretch", value, duration)
	tween.tween_property(skin, "squash_and_stretch", 1.0, duration * 1.8).set_ease(Tween.EASE_OUT)
