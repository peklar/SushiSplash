extends CharacterBody2D

var playerMovementOffset:Vector2 = Vector2(0,0) #dobesedno premakne x in y koordinato v tisto smer
var playerMovementOffsetScale:Vector2 = Vector2(1,1) #se pomnoži z x in y koordinato
var screenSize:Vector2 = Vector2(1920,1080)
#var boatRef
var boatStartYPos:int = 0
var lerpSpeed:float = 8

var health:int = 3

var canTurn:bool = true

func _ready() -> void:
	#boatRef = get_parent().get_node("Boat")
	boatStartYPos = get_parent().get_node("Boat").position.y-50
	$PlayerUi/HeartsIdleAnimationPlayer.play("idle")
	$PlayerUi.visible = true
	pass

func _on_fish_detection_area_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent().get_groups().has("Fish"):
		get_parent().fish_collected(area.get_parent().get_parent())
		area.get_parent().get_parent().get_collected()
		$AnimationPlayerAdvanced.stop()
		$AnimationPlayerAdvanced.play("CatchFish")
		$NetAnimationPlayer.stop()
		$NetAnimationPlayer.play("Catch")
		
		$CatchFish.stop()
		$CatchFish.play()
		$CatchFish2.pitch_scale = get_parent().comboMulti
		$CatchFish2.stop()
		$CatchFish2.play()
		pass
	pass # Replace with function body.

func play_land_animation():
	#print("play_land_animation")
	$AnimationPlayerAdvanced.stop()
	$AnimationPlayerAdvanced.play("LandInBoat")
	pass

var playerInBoat:bool = true
func set_player_position(newPos:Vector2,delta):
	newPos = ((newPos-screenSize/2)*playerMovementOffsetScale)+screenSize/2
	newPos +=playerMovementOffset
	
	
	if newPos.y >= boatStartYPos-20:
		newPos.y = boatStartYPos-20
		if playerInBoat:
			#$SpriteContainer.modulate = Color("636363")
			playerInBoat = false
			#get_parent().get_node("Boat").player_landed_in_boat()
			play_land_animation()
			return
		pass
			#$AnimationPlayerBasic.play("Land")
			#$SpriteContainer/Sprite2D.texture = load("res://Player/PlayerWaiting.png")
	else:
		if !playerInBoat:
			#$SpriteContainer.modulate = Color("ffffff")
			playerInBoat = true
			$AnimationPlayerAdvanced.stop()
			$AnimationPlayerAdvanced.play("Jump")
			#$SpriteContainer/Sprite2D.texture = load("res://Player/Player.png")
	
	#if newPos.y >= boatStartYPos-20:
		#newPos.y = boatStartYPos-20
		#if $FishDetectionArea.monitoring:
			##$SpriteContainer.modulate = Color("636363")
			#$FishDetectionArea.monitoring = false
			#get_parent().get_node("Boat").player_landed_in_boat()
			#$AnimationPlayerBasic.stop()
			#$AnimationPlayerBasic.play("Land")
			##$SpriteContainer/Sprite2D.texture = load("res://Player/PlayerWaiting.png")
	#else:
		#if !$FishDetectionArea.monitoring:
			##$SpriteContainer.modulate = Color("ffffff")
			#$FishDetectionArea.monitoring = true
			#$AnimationPlayerBasic.stop()
			#$AnimationPlayerBasic.play("Jump")
			##$SpriteContainer/Sprite2D.texture = load("res://Player/Player.png")
	
	if canTurn:
		#player is moving left
		if newPos.x<global_position.x and $SpriteContainer.scale.x != -0.64:
			$SpriteContainer.scale = Vector2(-0.64,0.64)
			canTurn = false
			$JustTurnedTimer.start()
			pass
		#palyer is moving right
		elif newPos.x>global_position.x and $SpriteContainer.scale.x != 0.64:
			$SpriteContainer.scale = Vector2(0.64,0.64)
			canTurn = false
			$JustTurnedTimer.start()
			pass
	
	
	
	var direction = newPos - global_position
	var distance = direction.length()
	
	##možna metoda
	#if distance >1:
		#var move = direction.normalized() * Vector2(1550,7500) * delta
		#if move.length() > distance:
			#global_position = newPos # Snap if we're going to overshoot
		#else:
			#global_position += move
	#else:
		#var weight = 1 - exp(-8 * delta)
		#global_position = lerp(global_position,newPos,weight)
	#print(distance)
	
	##trenutna metoda
	#var weight = 1 - exp(-lerpSpeed * delta)
	#global_position = lerp(global_position,newPos,weight)
	
	#stara metoda
	global_position = lerp(global_position,newPos,0.4)
	
	#global_position = newPos
	pass

func update_player_health(updateAmount:int):
	var hIndex:int = 1
	health+=updateAmount
	if health>3:
		health = 3
	if health<0:
		health = 0
	$PlayerUi/HeartHurtAnimationPlayer.play("Hurt")
	print(str("updating player health. new health is ",health))
	for c in $PlayerUi/HeartsContainer.get_children():
		if hIndex<=health:
			c.get_node("Container1/Container2/Sprite").frame = 0
		else:
			c.get_node("Container1/Container2/Sprite").frame = 1
		hIndex+=1
		pass
	if health<=0:
		get_parent().player_ran_out_of_health()
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		update_player_health(-1)
		pass
	pass


func _on_just_turned_timer_timeout() -> void:
	canTurn = true
	pass # Replace with function body.
