extends Node2D

var rotationSmoothener:int = 120
@export var lerpPlayerBias:Curve
var playerRef:CharacterBody2D

func _ready() -> void:
	playerRef = get_parent().playerRef
	pass

func _process(delta: float) -> void:
	var playerPos = get_parent().playerRef.global_position
	#lerpPlayerBias.sample()
	#print(1-clamp(global_position.y-playerPos.y-47,0,200)/200.0)
	
	#var lerpSpeed = 0.3*delta*40
	#print(delta*40)
	#if delta*40>0.8:
		#delta = 0.8
	var lerpSpeed = (1-clamp(global_position.y-playerPos.y-47,0,1000)/1000.0)*delta*40
	if lerpSpeed>0.8:
		lerpSpeed = 0.8
	
	var newPos = Vector2(lerp(global_position.x,playerPos.x,lerpSpeed),global_position.y)
	
	#for nice visual effect so that the boat rotates a bit when moving
	#if (global_position.x-playerPos.x)<0:
		#var newRotation = -global_position.distance_to(newPos)/rotationSmoothener
		#if newRotation < -0.5:
			#newRotation = -0.5
		#rotation = newRotation
		#$AnimationContainer/Container/Sprite2D.scale = Vector2(1,1)
	#else:
		#var newRotation = global_position.distance_to(newPos)/rotationSmoothener
		#if newRotation > 0.5:
			#newRotation = 0.5
		#rotation = newRotation
		#$AnimationContainer/Container/Sprite2D.scale = Vector2(-1,1)
	
	if playerRef.get_node("SpriteContainer").scale.x>0:
		var newRotation = -global_position.distance_to(newPos)/rotationSmoothener
		if newRotation < -0.5:
			newRotation = -0.5
		rotation = newRotation
		$AnimationContainer/Container/Sprite2D.scale = Vector2(1,1)
	else:
		var newRotation = global_position.distance_to(newPos)/rotationSmoothener
		if newRotation > 0.5:
			newRotation = 0.5
		rotation = newRotation
		$AnimationContainer/Container/Sprite2D.scale = Vector2(-1,1)
	
	
	global_position = newPos
	pass

func player_landed_in_boat():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Land")
	
	play_random_boat_splash()
	
	for a in $BoatTrashDetection.get_overlapping_areas():
		if a.is_in_group("Trash"):
			a.collect()
			pass
		if a.get_parent().is_in_group("WaterPoint"):
			a.get_parent().apply_force(-400+randi_range(-150,150))
			pass
		pass
	
	$BoatParticles.restart()
	pass

@warning_ignore("narrowing_conversion")
func play_random_boat_splash(volume:int = -34.5):
	#print("random boat sound sfx played")
	if randi()%2==0:
		$BoatLand.volume_db = volume
		$BoatLand.pitch_scale = randf_range(1,1.4)
		$BoatLand.stop()
		$BoatLand2.stop()
		$BoatLand.play()
	else:
		$BoatLand2.volume_db = volume
		$BoatLand2.pitch_scale = randf_range(1,1.4)
		$BoatLand.stop()
		$BoatLand2.stop()
		$BoatLand2.play()
		pass
	pass

func play_hurt_audio():
	$BoatHurt1.pitch_scale = randf_range(0.9,1.3)
	$BoatHurt1.play()
	pass

func _on_boat_trash_detection_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("Player"):
		player_landed_in_boat()
		area.get_parent().play_land_animation()
		pass
	pass # Replace with function body.
