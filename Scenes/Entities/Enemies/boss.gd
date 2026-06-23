extends Enemy

const simple_attack = {
	'slice' : "2H_Melee_Attack_Slice",
	'spin' : "2H_Melee_Attack_Spin",
	'range' : "1H_Melee_Attack_Stab"
}
@export var spin_speed = 6
var spinning := false

func _physics_process(delta: float) -> void:
	_move_to_player(delta)


func _on_attack_timer_timeout() -> void:
	$Timers/AttackTimer.wait_time = rng.randf_range(4.0, 5.5)
	if position.distance_to(player.position) < 5.0:
		_melee_attack_animation()
	else:
		if rng.randi() % 2:
			_range_attack_animation()
		else:
			_spin_attack_animation()
		
func _spin_attack_animation() -> void:
	var tween = create_tween()
	tween.tween_property(self, "speed", spin_speed, 0.5)
	tween.tween_method(_spin_transition, 0.0, 1.0, 0.3)
	$Timers/AttackTimer.stop()
	spinning = true

func _spin_transition(value: float) -> void:
	$AnimationTree.set("parameters/SpinBlend/blend_amount", value)
	

func _range_attack_animation() -> void:
	_stop_movement(1.5, 1.5)
	attack_animation.animation = simple_attack['range']
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func _melee_attack_animation() -> void:
	attack_animation.animation = simple_attack['slice' if rng.randi() % 2 else 'spin']
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if spinning:
		await get_tree().create_timer(rng.randf_range(1.0, 2.0)).timeout
		var tween = create_tween()
		tween.tween_property(self, "speed", walk_speed, 0.5)
		tween.tween_method(_spin_transition, 1.0, 0.0, 0.3)
		$Timers/AttackTimer.start()
