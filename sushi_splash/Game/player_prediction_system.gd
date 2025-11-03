extends Node

@export var jumpCurve:Curve

var detectionLinePos:int = 500

var ascending:bool = false
var hasAlreadyLanded:bool = true

var latestPacket:Vector2 = Vector2.ZERO
var simulatedPacket:Vector2 = Vector2.ZERO
var playerRef:CharacterBody2D

var movementSpeedX:float = 0


@export var debugPacket:bool = false

func _ready() -> void:
	latestPacket = get_parent().latest_packet
	if debugPacket:
		$PacketSprite.visible = true
		$DebugDetectionLine.visible = true
		$DebugDetectionLine.position.y = detectionLinePos
		pass
	pass

func new_position_recieved(newPos:Vector2):
	#print(newPos)
	if newPos.y< latestPacket.y:
		ascending = true
		if hasAlreadyLanded and newPos.y<detectionLinePos:
			jump_detected()
		pass
	else:
		ascending = false
		pass
	
	if newPos.y>700:
		$AnimationPlayer.play("RESET")
		hasAlreadyLanded = true
		pass
	
	#print(ascending)
	
	
	movementSpeedX = (newPos.x-latestPacket.x)*0.005
	latestPacket = newPos
	simulatedPacket = latestPacket
	
	if debugPacket:
		$PacketSprite.global_position = latestPacket
	pass

func _process(delta: float) -> void:
	playerRef.set_player_position(
		latestPacket,
		delta
		)
	
	return
	simulatedPacket+=Vector2(movementSpeedX,0)
	
	playerRef.set_player_position(
		Vector2(
			simulatedPacket.x,
			$Ypos.global_position.y
		),
		delta
		)
	#print(Vector2(
			#latestPacket.x,
			#$Ypos.global_position.y
		#))
	movementSpeedX = movementSpeedX - (movementSpeedX*0.01)
	#print(movementSpeedX)
	
	pass

func jump_detected():
	hasAlreadyLanded = false
	$AnimationPlayer.play("PlayerJump")
	if debugPacket:
		print("jump detected!!!")
	pass

func falling_detected():
	pass

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="PlayerJump":
		hasAlreadyLanded = true
		pass
	pass # Replace with function body.
