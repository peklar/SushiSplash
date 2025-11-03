extends FishClass

@export var HeightCurve:Curve

@export var followNetInsteadOfBoat:bool = true

var aliveTime:float = 4
var targetPos:Vector2
var startPos:Vector2
var edgeOffset:int = 200

var maxJumpHeight:float = 0.8
var minJumpHeight:float = 1.75

var maxLifetime:float = 3
var minLifetime:float = 5
var activeFishNode:Node = null


func _ready() -> void:
	startPos = global_position
	$SpriteContainer.visible = true
	#check which side the fish has spawned on so it can jump in the oposite direction
	#right
	@warning_ignore("integer_division")
	if global_position.x>(1920/2):
		@warning_ignore("integer_division")
		targetPos = global_position-Vector2(randi_range(0+edgeOffset,(1920/2)-edgeOffset),0)
		$SpriteContainer.scale = Vector2(1,-1)
		pass
	#left
	else:
		@warning_ignore("integer_division")
		targetPos = global_position+Vector2(randi_range(0+edgeOffset,(1920/2))-edgeOffset,0)
		pass
	
	#if fish would jump very small distance double it
	if targetPos.distance_to(startPos) < 100:
		targetPos.x*=2
	
	#randomize alive timer just a bit
	aliveTime = randf_range(minLifetime,maxLifetime)
	
	#randomize jump height a bit
	@warning_ignore("narrowing_conversion")
	jumpHeight*=randf_range(minJumpHeight,maxJumpHeight)
	
	$EraseTimer.start(aliveTime)
	if aliveTime/8.0>1:
		$SplashParticleTimer.start(1)
	else:
		$SplashParticleTimer.start(aliveTime/8.0)
	$AnimationPlayer.play("Spawn")
	#$FishAnimationPlayer.play("FlyingFish")
	pass

var playerNetCenterRef:Node2D
var boatRef:Node2D

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if !wasCollected:
		var newPos = Vector2(
			lerp(startPos.x,targetPos.x,1-($EraseTimer.time_left/aliveTime)),
			startPos.y-HeightCurve.sample($EraseTimer.time_left/aliveTime)*jumpHeight
		)
		$SpriteContainer.look_at(global_position+global_position.direction_to(newPos))
		global_position = newPos
		pass
	else:
		global_position = lerp(global_position,playerNetCenterRef.global_position,lerpStrenght)
		pass
	pass

func _on_erase_timer_timeout() -> void:
	var game = get_tree().root.get_node("Game")
	if game.comboActive:
		game.comboCount = 0
		game.comboMulti = 1.0
		game.comboActive = false
		pass
	queue_free()

var wasCollected:bool=false
func get_collected():
	if wasCollected:
		return
	if followNetInsteadOfBoat:
		playerNetCenterRef = get_parent().get_parent().playerNetCenter
	else:
		playerNetCenterRef = get_parent().get_parent().get_node("Boat")
	wasCollected = true
	match randi()%5:
		0:
			$PickupParticles.color = Color("#8000ff")
		1:
			$PickupParticles.color = Color("#ff0004")
		2:
			$PickupParticles.color = Color("#fff700")
		3:
			$PickupParticles.color = Color("#4cff00")
		4:
			$PickupParticles.color = Color("#00ffd9")
	$PickupParticles.emitting = true

	$AnimationPlayer.play("Collected")
	$SpriteContainer/DetectionArea.set_deferred("monitorable",false)
	$SpriteContainer/DetectionArea/CollisionShape2D.set_deferred("disabled",true)
	#set_process(false)
	pass

@warning_ignore("unused_parameter")
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	# To uncomentaj če želiš dodat ta "fish spawn protection"
	#if anim_name=="Spawn":
		#$SpriteContainer/DetectionArea.monitorable = true
		#$SpriteContainer/DetectionArea/CollisionShape2D.disabled = false
		#pass
	pass # Replace with function body.
	
func play_fish_animation(anim_name:String) -> void:
	if activeFishNode and activeFishNode.has_node("AnimationPlayer"):
		var ap = activeFishNode.get_node("AnimationPlayer")
		if ap.has_animation(anim_name):
			ap.play(anim_name)
		else:
			push_warning("Animation '%s' not found on %s" % [anim_name, activeFishNode.name])
	else:
		push_warning("No AnimationPlayer on %s" % activeFishNode)

func fish_setup(textureName: String) -> void:
	fishName = textureName

	var fishContainer := $SpriteContainer/FlyingFish

	# Hide all fish variants first
	for fish in ["AsianCarp", "Mullet", "FlyingFish", "NeedleFish", "AtlanticMahi"]:
		if fishContainer.has_node(fish):
			fishContainer.get_node(fish).visible = false

	# Set the active fish node
	if fishContainer.has_node(textureName):
		activeFishNode = fishContainer.get_node(textureName)
		activeFishNode.visible = true
		activeFishNode.get_node("AnimationPlayer").play("Idle")
	else:
		push_error("Fish node '%s' not found under SpriteContainer/FlyingFish!" % textureName)
		return

	# Fish-specific setup
	match textureName:
		"AtlanticMahi":
			score = 450
			activeFishNode.get_node("Fin").position = Vector2(-19, -11)
			minJumpHeight = 1.1
			maxJumpHeight = 2.0
			minLifetime = 2.0
			maxLifetime = 4.0
		"FlyingFish":
			score = 240
			activeFishNode.get_node("Fin").position = Vector2(-10, -3)
			minJumpHeight = 1.2
			maxJumpHeight = 1.75
			minLifetime = 3.0
			maxLifetime = 5.0
		"Mullet":
			score = 150
			activeFishNode.get_node("Fin").position = Vector2(-19, 4)
			minJumpHeight = 1.1
			maxJumpHeight = 1.3
			minLifetime = 4.0
			maxLifetime = 5.0
		"NeedleFish":
			score = 350
			activeFishNode.get_node("Fin").position = Vector2(-20.5, 7)
			minJumpHeight = 1.25
			maxJumpHeight = 1.75
			minLifetime = 4.0
			maxLifetime = 6.0
		"AsianCarp":
			score = 200
			activeFishNode.get_node("Fin").position = Vector2(-9.5, -1)
			minJumpHeight = 1.1
			maxJumpHeight = 1.4
			minLifetime = 4.0
			maxLifetime = 5.0
		_:
			push_warning("Unknown fish type '%s'" % textureName)
			score = 100
			activeFishNode = fishContainer.get_node("FlyingFish")
			activeFishNode.get_node("Sprite2D").position = Vector2(-10, -3)
			minJumpHeight = 1.6
			maxJumpHeight = 1.75
			minLifetime = 3.0
			maxLifetime = 5.0

	play_fish_animation("Idle")
	pass

func _on_splash_particle_timer_timeout() -> void:
	$SpriteContainer/FlyingFish/CPUParticles2D.emitting = false
	pass # Replace with function body.

func is_ascending()->bool:
	if $EraseTimer.time_left/aliveTime<0.5:
		return true
	return false

func _on_cpu_particles_2d_finished() -> void:
	#print("fish deleted")
	queue_free()
	pass # Replace with function body.

var lerpStrenght:float = 0.025
func animation_half_finished():
	lerpStrenght = 0.1
	pass
func animation_almost_finished():
	lerpStrenght = 0.2
	pass
