extends Enemy

func _physics_process(delta: float) -> void:
	_move_to_player(delta)


func _on_attack_timer_timeout() -> void:
	$Timers/AttackTimer.wait_time = rng.randf_range(2.0, 3.0)
	if position.distance_to(player.position) < attack_radius:
		$AnimationTree.set('parameters/AttackOneShot/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
