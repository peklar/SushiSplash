extends Node2D

func _ready() -> void:
	$AnimationPlayer.play("Idle")
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	#print("animation finished")
	#print(anim_name)
	if anim_name=="Idle":
		$AnimationPlayer.play("Idle")
		$AnimationPlayer.speed_scale = randf_range(0.5,0.7)
		#print("Idle started again")
		pass
	#else:
		##print("tree stopping cuz anime name ")
		#print(anim_name)
	pass # Replace with function body.
