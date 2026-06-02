extends Node3D

@onready var move_state_machine = $AnimationTree.get("parameters/MoveStateMachine/playback")

func _set_move_state(state_name: String) -> void:
	move_state_machine.travel(state_name)

func _attack() -> void:
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func _defend(forward: bool) -> void:
	var tween = create_tween()
	tween.tween_method(_defend_change, 1.0 - float(forward), float(forward), 0.25)
	
func _defend_change(value: float) -> void:
	$AnimationTree.set("parameters/ShieldBlend/blend_amount", value)
