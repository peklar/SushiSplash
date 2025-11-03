extends Node2D

var currentWave:int = 1
var currentScore:int = 0
var edgeOffset:int = 200
var comboCount:int = 0
var comboMulti:float = 1.0
var comboMultiMax:float = 2.0
var comboActive:bool = false
var countdown:int = 5
var gameStarted:bool = false
var gameEnd: int = 5
var screen_center: = Vector2(1920, 1080) / 2.0
var screen_half: = screen_center
var latest_packet: Vector2 = Vector2(940, 677) #Vector2.ZERO #

@onready var buoyAnimation: AnimationPlayer = $Boat/AnimationContainer/Container/Sprite2D/Buoy/AnimationPlayer
@onready var planeAnimation: AnimationPlayer = $Plane/AnimationPlayer
@onready var fishiesAnimation: AnimationPlayer = $Fishies/AnimationPlayer
@onready var comboLabel: RichTextLabel = $UI/ComboLabel
@onready var comboAnimation: AnimationPlayer = $UI/ComboAnimation
@onready var osc_server: OSCServer = $OSCServer
@onready var playerRef:CharacterBody2D = $Player
@onready var playerNetCenter:Node2D = $Player/SpriteContainer/NewSprite/LeftHand/Stick/Net/NetCenter

@onready var fishTimer:Timer = $Timers/FishTimer
@onready var trashTimer:Timer = $Timers/TrashTimer
@onready var startTimer:Timer = $Timers/StartTimer
@onready var gameTimer:Timer = $Timers/GameTimer
@onready var gameEndTimer:Timer = $Timers/GameEndTimer
@onready var finalCountdownTimer:Timer = $Timers/FinalCountdownTimer
@onready var sharkSpawnTimer:Timer = $Shark/SharkTimer

@onready var timeLabel = $UI/TimeLeft
@onready var start = $UI/Start
@onready var scoreLabel = $UI/Score
@onready var exitToMenuLabel = $GameOverUI/ExitToMenuLabel


var fontTimeLabel:String = "[outline_size=20][p align=center][font_size=80]"
var fontStartLabel:String = "[outline_size=30][p align=center][font_size=170]"
var fontScoreLabel:String = "[outline_size=30][p align=right][font_size=150]"
var fontExitToMenu:String = "[outline_size=20][p align=right][font_size=50]"
var fontContinueLabel:String = "[center][wave amp=50.0 freq=5.0 connected=1][color=white][font_size=120]"

@onready var gameOverUI = $GameOverUI
@onready var finalScore = $GameOverUI/FinalScore

@onready var parallaxL3_1 = $ParallaxLayers/ParallaxL3_1
@onready var parallaxL3_2 = $ParallaxLayers/ParallaxL3_2

@export var gameDuration:int = 60
@export var trashSpawnDuration:float = 13
@export var fishSpawnDuration:float = 2.0

@export var remapX:Vector2 = Vector2(-1,1)
@export var remapY:Vector2 = Vector2(-1,1)

@export var playerLerpSpeed:float = 126

@export var coloredComboLabel:bool = true

@export var max_offset: float = 200.0

func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	#osc_server.connect("message_received", Callable(self, "_on_osc_message_received"))
	fishiesAnimation.play("FishHorde")
	planeAnimation.play("PlaneFlight")
	buoyAnimation.play("BuoyAnimation")
	randomize()
	
	$Player.lerpSpeed = playerLerpSpeed
	
	gameStarted = false
	start.text = str(fontStartLabel, countdown)
	#startTimer.start()
	
	$PlayerPredictionSystem.playerRef = $Player
	
	$Boat.playerRef = $Player
	
	show_start_game()
	timeLabel.text = str(fontTimeLabel,gameDuration)
	#$UI/WaveLabel/WaveAnimationPlayer.stop()
	show_wave_label() #zažene igro
	#show_round_score_ui()
	pass

#func get_mouse_screen_index() -> int:
	#var mouse_pos = DisplayServer.mouse_get_position()
	#var screen_count = DisplayServer.get_screen_count()
#
	#for i in screen_count:
		#var rect = DisplayServer.screen_get_usable_rect(i)
		#if rect.has_point(mouse_pos):
			#return i
	#return -1 # Not found (very rare)

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if gameTimer.time_left > 0:
		update_time_label()
	
	#var player_pos = get_global_mouse_position() #staro
	
	#novi način
	#var mouse_pos = DisplayServer.mouse_get_position()
	#var window_pos = get_window().position
	#var local_mouse = mouse_pos - window_pos
	#var screen_index = get_mouse_screen_index()
	#var player_pos = Vector2(local_mouse)*Vector2(1920,1080)/Vector2(get_window().size)
	var player_pos
	
	if !mouseInput:
		player_pos = latest_packet
	#else:
		#player_pos = get_global_mouse_position()
	
	#playerRef.set_player_position(player_pos,delta)
	
	#print("Mouse on screen:", screen_index)
	#print("Mouse OS pos:", mouse_pos)
	#print("Mouse in game window:", player_pos)

	#parallaxL1_1.position = player_pos * -0.015 # Sea Layer
	#parallaxL1_2.position = player_pos * -0.02 # Sea Layer
	#parallaxL1_3.position = player_pos * -0.025 # Sea Layer
	#
	#parallaxL2_1.position = player_pos * 0.015 # Land Layer
	#parallaxL2_2.position = player_pos * 0.01 # Land Layer
	#parallaxL2_3.position = player_pos * 0.005 # Land Layer
	
	parallaxL3_1.position = player_pos * -0.025 # sky Layer
	parallaxL3_2.position = player_pos * 0.015 # Cloud Layer
	
func show_combo_label(points: int):
	var text := ""
	if coloredComboLabel:
		var availableColors = ["[color=#FF5E61]","[color=#66FF63]","[color=#6DFFAA]","[color=#30ACFF]","[color=#B16DFF]","[color=#FF6BF2]","[color=#FFAB2D]"]
		text+= availableColors[randi()%availableColors.size()]
	
	if comboCount >= 2:
		text += "[font_size=70][outline_size=8]Combo x%d!\n" % comboCount
	
	text += "[font_size=80][outline_size=6]+%d pts" % points
	
	comboLabel.text = text
	comboLabel.rotation_degrees = randi_range(5,-5)
	comboLabel.visible = true
	comboLabel.modulate.a = 1.0
	comboAnimation.stop()
	comboAnimation.play("combo_popup")

func hide_combo_label():
	comboLabel.visible = false
	
func fish_collected(fish: FishClass):
	if comboCount >= 2:
		comboMulti += 0.1
		if comboMulti > comboMultiMax:
			comboMulti = comboMultiMax
	else:
		comboMulti = 1.0

	comboCount += 1
	comboActive = true

	var points = int(fish.score * comboMulti)
	currentScore += points

	scoreLabel.text = str(fontScoreLabel," ", currentScore, " ")
	$UI/ScoreAnimationPlayer.play("Collect")

	# Always show points; if comboCount ≥ 2, combo will be included
	show_combo_label(points)

func show_combo_text(pos: Vector2, multiplier: float):
	if comboCount >= 3:
		var popup_scene = load("res://ComboPopup.tscn")
		var popup = popup_scene.instantiate()
		popup.text =  str("[outline_size=10][font_size=40]","Combo %.1fx" % multiplier)
		get_tree().current_scene.add_child(popup)
		popup.global_position = pos
		
func spawn_fish(fishName:String=""):
	var spawnPos:Vector2 = Vector2(randi_range(0+edgeOffset,1920-edgeOffset),1080)

	var hint = load("res://Fish/FishSpawnParticles.tscn").instantiate()
	hint.global_position = spawnPos
	add_child(hint)

	await get_tree().create_timer(1).timeout
	
	if !gameStarted:
		print("game ended fish spawn aborted")
		return
	
	var inst = load("res://Fish/Fish.tscn").instantiate()
	
	if fishName=="":
		var fishOptions = ["Mullet","AsianCarp","FlyingFish","NeedleFish","AtlanticMahi"]
		fishName = fishOptions[randi()%fishOptions.size()]
		pass
	
	inst.fish_setup(fishName) #Doloci fish setup (Fish, Fish2, Fish3..)
	
	inst.global_position = spawnPos
	$FishContainer.add_child(inst)
	pass

var fastFishSpawnIndex:int = 0
func _on_fish_timer_timeout() -> void:
	if gameStarted:
		
		
		#print("Fish spawned at:", Time.get_ticks_msec())
		if randi()%4==0 and fastFishSpawnIndex<3:#25% šansa za fast second fish
			fishTimer.start(randf_range(0.1,0.5))
			fastFishSpawnIndex+=1
			pass
		else:
			fastFishSpawnIndex = 0
			fishTimer.start(fishSpawnDuration-randf_range(0,1.0))
			pass
		spawn_fish()
		#spawn_fish("Mullet")
		#spawn_fish("AsianCarp")
		#spawn_fish("FlyingFish")
		#spawn_fish("NeedleFish")
	pass # Replace with function body.

func update_time_label():
	var time_left = int(ceil(gameTimer.time_left))
	@warning_ignore("integer_division")
	var minutes = time_left / 60
	var seconds = time_left % 60
	var formatted_time = "%02d:%02d" % [minutes, seconds]
	
	timeLabel.text = str(fontTimeLabel, formatted_time)
	pass

func _on_game_timer_timeout() -> void:
	end_game();
	pass

func start_final_countdown():
	if finalCountdownTimer.is_stopped():
		timeLabel.visible = true
		gameEnd = 3
		finalCountdownTimer.get_node("Ring").pitch_scale = 1
		finalCountdownTimer.get_node("Ring").play()
		$Timers/StartTimer/StartAnimationPlayer.play("InreaseInSize")
		$UI/Start.text = str(fontStartLabel,gameEnd)
		finalCountdownTimer.start()
		
func _on_final_countdown_timer_timeout():
	gameEnd -= 1
	if gameEnd > 0:
		timeLabel.visible = true
		finalCountdownTimer.get_node("Ring").pitch_scale = 1
		finalCountdownTimer.get_node("Ring").play()
		$Timers/StartTimer/StartAnimationPlayer.play("InreaseInSize")
		$UI/Start.text = str(fontStartLabel,gameEnd)
	else:
		timeLabel.visible = true
		finalCountdownTimer.get_node("Ring").pitch_scale = 1.2 # lahko se doda drug game over effekt
		finalCountdownTimer.get_node("Ring").play()
		#$Timers/StartTimer/StartAnimationPlayer.play("InreaseInSize")
		$UI/Start.text = str(fontStartLabel,"Time's up!")
		timeLabel.visible = false
		scoreLabel.visible = false
		finalCountdownTimer.stop()
		
func _on_start_timer_timeout() -> void:
	countdown -= 1
	print(countdown)
	if countdown > 0:
		start.visible = true
		$Timers/StartTimer/StartAnimationPlayer.play("InreaseInSize")
		start.text = str(fontStartLabel, countdown)
		startTimer.start()
		startTimer.get_node("Ring").pitch_scale = 1
	else:
		start.visible = true
		timeLabel.visible = true
		update_time_label()
		print("==> STARTING fishTimer")
		fishTimer.start(0.1)
		trashTimer.wait_time = trashSpawnDuration-randi_range(0,6)
		trashTimer.start()
		$Timers/StartTimer/StartAnimationPlayer.play("InreaseInSize")
		start.text = str(fontStartLabel, "GO!")
		startTimer.stop()
		start.text = ""
		gameStarted = true
		gameTimer.start(gameDuration)
		update_time_label()
		start_shark_timer()
		gameEndTimer.start(gameDuration-3)
		startTimer.get_node("Ring").pitch_scale = 1.2
		
	startTimer.get_node("Ring").stop()
	startTimer.get_node("Ring").play()
	pass # Replace with function body.

func end_game():
	gameStarted = false
	fishTimer.stop()
	sharkSpawnTimer.stop()
	
	for fish in $FishContainer.get_children():
		if !fish.wasCollected:
			vanish_node_with_effect(fish)
		
	for trash in $TrashContainer.get_children():
		vanish_node_with_effect(trash)
	
	timeLabel.text =str(fontTimeLabel, "00:00") 
	$UI/Start.text = str(fontStartLabel, "Time's Up!")
	$UI/Start.visible = true
	
	$Shark/Center/SharkAnimationPlayer.stop()
	$Shark/Center/SharkAnimationPlayer.play("RESET")
	
	await get_tree().create_timer(1.5).timeout
	
	finalScore.text = str("[wave amp=10.0 freq=5.0 connected=0][outline_size=20][font_size=100][center]", "Current score: \n", currentScore)
	$UI/UIFadeAnimation.play("fade_out_times_up")

func restart_game():
	currentWave+=1
	countdown = 3
	startTimer.start()
	start.visible = true
	
	start.modulate = Color("#ffffff",1)
	$Timers/StartTimer/StartAnimationPlayer.play("InreaseInSize")
	finalCountdownTimer.get_node("Ring").pitch_scale = 1
	finalCountdownTimer.get_node("Ring").play()
	$UI/Start.text = str(fontStartLabel, "3")
	timeLabel.visible = false
	scoreLabel.visible = true
	
	gameTimer.start()
	gameEndTimer.start()
	
	finalScore.visible = false
	
	#currentScore = 0
	comboCount = 0
	comboActive = false
	scoreLabel.text = str(fontScoreLabel," ", currentScore, " ")
	
	exitToMenuLabel.get_node("ExitToMenuTimer").stop()
	exitToMenuLabel.visible = false
	
	$JumpToContinue.visible = false
	$GameOverUI/AnimationPlayer.stop()
	$GameOverUI/ContinueLabel.visible = false
	$JumpToContinue.set_deferred("monitoring",false)
	
	$UI/ScreenDarkenRect.visible = false
	
	#get_tree().call_deferred("reload_current_scene")
	pass

func quit_game():
	get_tree().quit()
	pass


func _on_restart_button_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("Player"):
		restart_game();
	pass


func _on_quit_button_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("Player"):
		quit_game();
	pass


func _on_jump_to_continue_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("Player"):
		#restart_game();
		#show_wave_label()
		pass
	pass # Replace with function body.


func _on_trash_timer_timeout() -> void:
	if gameStarted:
		spawn_trash()
		trashTimer.start(trashSpawnDuration-randi_range(0,6))
	pass
	
func spawn_trash(trashName: String = ""):
	var spawnPos: Vector2
	var directionLeftToRight = bool(randi()%2)

	if directionLeftToRight:
		spawnPos = Vector2(-300, 838)
	else:
		spawnPos = Vector2(2320, 838)

	var inst = load("res://Trash/Trash.tscn").instantiate()
	
	if trashName=="":
		var trashOptions = ["Barrel","Plastic","Old_Shoe","Seaweed"]
		trashName = trashOptions[randi()%trashOptions.size()]
		pass
		
		inst.trash_setup(trashName)
		
		inst.global_position = spawnPos
		
		$TrashContainer.add_child(inst)
		pass
		
func vanish_node_with_effect(node: Node2D):
	var vanish = preload("res://VanishParticles.tscn").instantiate()
	vanish.global_position = node.global_position
	get_tree().current_scene.add_child(vanish)
	node.queue_free()
	
func trash_collected(trash: TrashClass) -> void:
	trash.get_node("CollisionShape2D").set_deferred("disabled", true)
	$TrashCollectSound.play()
	var points = trash.score
	currentScore += points
	var popup_scene = load("res://Trash/TrashCollectPopup.tscn")
	var popup = popup_scene.instantiate()
	var popup_node = popup.get_node("TrashPopup")
	popup_node.text = "[outline_size=10][font_size=40]%+d" % points
	get_tree().current_scene.add_child(popup)
	popup.global_position = trash.global_position + Vector2(0, -40)
	
	# Animacija za trashcollectlabel
	var tween = popup.create_tween()
	tween.tween_property(popup, "position", popup.position + Vector2(0, -50), 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(popup_node, "modulate:a", 0.0, 0.7)
	tween.tween_callback(Callable(popup, "queue_free"))
	
	scoreLabel.text = str(fontScoreLabel," ",currentScore," ")
	$UI/ScoreAnimationPlayer.play("Collect")
	
	print("Trash collected:", trash.trashName, "Score:", points)


func _on_game_end_timer_timeout() -> void:
	start_final_countdown()
	pass # Replace with function body.

func _on_time_up_fade_complete():
	if currentWave>=6:
		show_final_score_ui_game_over()
		pass
	else:
		show_round_score_ui()

func show_round_score_ui():
	$UI/Start.visible = false
	gameOverUI.visible = true
	scoreLabel.visible = false
	finalScore.visible = false
	finalScore.text = str("[wave amp=10.0 freq=5.0 connected=0][outline_size=20][font_size=100][center]", "Current score: \n", currentScore)
	$UI/UIFadeAnimation.play("fade_out_score")
	
	
	#$JumpToContinue.visible = true
	#$GameOverUI/AnimationPlayer.play("ContinueLabel")
	#$GameOverUI/ContinueLabel.text = str(fontContinueLabel,"Jump To Continue")
	#$GameOverUI/ContinueLabel.visible = true
	##$JumpToContinue.set_deferred("monitoring",true)
	#
	#exitToMenuIndex = 10
	#exitToMenuLabel.get_node("ExitToMenuTimer").start(1)
	#exitToMenuLabel.get_node("ExitToMenuLabelAnimationPlayer").play("ScaleBounce")
	#exitToMenuLabel.text = str(fontExitToMenu,"exiting game in ",exitToMenuIndex," ")
	#exitToMenuLabel.visible = true
	pass

#ko je dejansko zadnji wave
func show_final_score_ui_game_over():
	#$GameOverUI/FinalScoreParticles.emitting = true
	finalScore.visible = false
	$UI/Start.visible = false
	gameOverUI.visible = true
	#finalScore.visible = true
	#finalScore.text = str("[wave amp=10.0 freq=5.0 connected=0][outline_size=20][font_size=100][center]", "Your Final Score: %d" % currentScore)
	#$ScoreBoard.show_scoreboard(currentScore)
	$ScoreBoard_v3.generate_scoreboard(currentScore)
	timeLabel.visible = false
	$Player/PlayerUi.visible = false
	
	scoreLabel.visible = false
	
	exitToMenuIndex = 7
	exitToMenuLabel.get_node("ExitToMenuTimer").start(1)
	exitToMenuLabel.get_node("ExitToMenuLabelAnimationPlayer").play("ScaleBounce")
	exitToMenuLabel.text = str(fontExitToMenu,"exiting game in ",exitToMenuIndex," ")
	exitToMenuLabel.visible = true
	pass


var lastMsgTime:int = 0
@warning_ignore("unused_parameter")
func _on_osc_message_received(address: Variant, value: Variant, time: Variant) -> void:
	#if get_node_or_null("DebugUI") !=null:
		#$DebugUI.packet_recieved(address,value,time)
	#if address == "/packet":
		##print(str("packet '/packet' recieved, content size=",value.size(),"  content of packet:"))
		##for n in value:
			##print(n)
		#$UI/DebugLabel.text = str("Debug:(",float(value[0])," , ", float(value[1]),") [p]Time since last packet: ",Time.get_ticks_msec()-lastMsgTime,"ms")
		#lastMsgTime = Time.get_ticks_msec()
		##var norm = Vector2(float(value[0]), float(value[1]))
		#var norm = Vector2(
			#float(remap(float(value[6]),-1,1,remapX.x,remapX.y)),
			#float(remap(float(value[7]),-1,1,remapY.x,remapY.y))
			#)
		#latest_packet = norm * screen_half + screen_center * Vector2(1,-1)+Vector2(0,1080)
		#$PlayerPredictionSystem.new_position_recieved(latest_packet)
		#pass
	#elif address == "/posy":
		##print(str("packet '/posy' recieved, content value=",value,"  content of packet:"))
		#$UI/DebugLabel.text = str("Debug:(", float(value),") [p]Time since last packet: ",Time.get_ticks_msec()-lastMsgTime,"ms")
		#lastMsgTime = Time.get_ticks_msec()
		##var norm = Vector2(0, float(value))
		#var norm = Vector2(0, remap(float(value),-1,1,remapY.x,remapY.y))
		#
		#latest_packet.y = norm.y * screen_half.y + screen_center.y*-1+1080
		#$PlayerPredictionSystem.new_position_recieved(latest_packet)
		#pass
	#elif address == "/posx":
		##print(str("packet '/posx' recieved, content value=",value,"  content of packet:"))
		#$UI/DebugLabel.text = str("Debug:(", float(value),") [p]Time since last packet: ",Time.get_ticks_msec()-lastMsgTime,"ms")
		#lastMsgTime = Time.get_ticks_msec()
		##var norm = Vector2(float(value),0)
		#var norm = Vector2(remap(float(value),-1,1,remapX.x,remapX.y),0)
		#latest_packet.x = norm.x * screen_half.x + screen_center.x
		#pass
		#$PlayerPredictionSystem.new_position_recieved(latest_packet)
	#else:
		#print(str("!!!got another packet at address value '",address,"' and was discarded. contents of packet were:"))
		#for n in value:
			#print(n)
	pass


var mouseInput:bool = false
func _on_mouse_check_button_toggled(toggled_on: bool) -> void:
	print("mouse input toggled ",toggled_on)
	mouseInput = toggled_on
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	pass
	#print(event)
	if event is InputEventMouseMotion:
		latest_packet = event.position
		$PlayerPredictionSystem.new_position_recieved(latest_packet)
		
		pass
	if event is InputEventMouseButton:
		latest_packet = event.position
		$PlayerPredictionSystem.new_position_recieved(latest_packet)
		pass
	
	#samo za debug
	if event.is_action_pressed("ui_accept"):
		$Shark/Center/SharkAnimationPlayer.play("Bite")


var exitToMenuIndex:int = 7
func _on_exit_to_menu_timer_timeout() -> void:
	if exitToMenuIndex<=0:
		get_tree().quit()
	else:
		exitToMenuIndex-=1
		if exitToMenuIndex<9 and currentWave<6:
			$JumpToContinue.set_deferred("monitoring",true)
		exitToMenuLabel.get_node("ExitToMenuTimer").start(1)
		exitToMenuLabel.get_node("ExitToMenuLabelAnimationPlayer").play("ScaleBounce")
		exitToMenuLabel.text = str(fontExitToMenu,"exiting game in ",exitToMenuIndex," ")
		exitToMenuLabel.visible = true
	pass # Replace with function body.



func show_start_game():
	
	start.visible = false
	timeLabel.visible = false
	scoreLabel.visible = false
	finalScore.visible = false
	
	#exitToMenuLabel.get_node("ExitToMenuTimer").stop()
	exitToMenuLabel.visible = true
	
	$JumpToContinue.visible = true
	exitToMenuLabel.get_node("ExitToMenuTimer").start()
	$GameOverUI/AnimationPlayer.play("ContinueLabel")
	$GameOverUI/ContinueLabel.text = str(fontContinueLabel,"Jump To Start")
	$GameOverUI/ContinueLabel.visible = true
	
	#$JumpToContinue.set_deferred("monitoring",true)
	$UI/ScreenDarkenRect.color = Color("#00000071")
	$UI/ScreenDarkenRect.visible = true
	
	fishTimer.stop()
	trashTimer.stop()
	startTimer.stop()
	gameTimer.stop()
	gameEndTimer.stop()
	finalCountdownTimer.stop()
	sharkSpawnTimer.stop()
	pass



func show_wave_label():
	print("SHOW_WAVE_LABEL CALLED")
	start.visible = false
	timeLabel.visible = false
	scoreLabel.visible = false
	finalScore.visible = false
	exitToMenuLabel.get_node("ExitToMenuTimer").stop()
	exitToMenuLabel.visible = false
	$JumpToContinue.visible = false
	$GameOverUI/AnimationPlayer.stop()
	$GameOverUI/ContinueLabel.visible = false
	$JumpToContinue.set_deferred("monitoring",false)
	$UI/ScreenDarkenRect.visible = false
	
	#$UI/WaveLabel.visible = true
	$UI/WaveLabel.text = str("[outline_size=30][p align=center][font_size=170][center]Round ",currentWave)
	$UI/WaveLabel/WaveAnimationPlayer.play("DisplayWave")
	pass


func _on_wave_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "DisplayWave":
		restart_game()
		pass
	pass # Replace with function body.

func shark_bite():
	$Shark/SharkBiteSound.stop()
	$Shark/SharkBiteSound.play()
	for b in $Shark/Center/SharkDetectionArea.get_overlapping_areas():
		#print(b.get_parent())
		#print(b.get_parent().is_in_group("Boat"))
		if b.get_parent().is_in_group("Boat"):
			playerRef.update_player_health(-1)
			
			$Boat.play_random_boat_splash(-25)
			$Boat.play_hurt_audio()
			
			if $Shark/Center.scale.x>0:
				$Boat/AnimationPlayer2.play("shark_left")
				pass
			else:
				$Boat/AnimationPlayer2.play("shark_right")
				pass
			break
		pass
	pass


func _on_shark_timer_timeout() -> void:
	if randi()%2==0: #50 50 chance
		$Shark/Center.scale = Vector2(1,1)
		pass
	else:
		$Shark/Center.scale = Vector2(-1,1)
		pass
	$Shark/Center/SharkAnimationPlayer.play("Bite")
	pass # Replace with function body.

func start_shark_timer():
	var chosenTime:float = 0
	print(str("current wave is: ",currentWave))
	match currentWave-1:
		1:
			#print("wave time 1 for shark was chosen")
			chosenTime = 30
			#sharkSpawnTimer.start(30)
			pass
		2:
			#print("wave time 2 for shark was chosen")
			chosenTime = randi_range(20,30)+randf()
			#sharkSpawnTimer.start(randi_range(20,30)+randf())
			pass
		3:
			chosenTime = randi_range(15,20)+randf()
			#sharkSpawnTimer.start(randi_range(15,20)+randf())
			pass
		4:
			chosenTime = randi_range(5,15)+randf()
			#sharkSpawnTimer.start(randi_range(5,15)+randf())
			pass
		5:
			chosenTime = randi_range(4,12)+randf()
			#sharkSpawnTimer.start(randi_range(4,12)+randf())
			pass
		_:
			chosenTime = randi_range(7,15)+randf()*2
			#sharkSpawnTimer.start(randi_range(7,15)+randf()*2)
			pass
	if gameTimer.time_left<chosenTime+5:
		print("not starting shark timer")
		print(str(gameTimer.time_left," < ",chosenTime+5))
		return
	print(str("starting shark timer, ",gameTimer.time_left," > ",chosenTime+5))
	sharkSpawnTimer.start(chosenTime)
	pass

func _on_shark_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="Bite":
		if gameStarted:
			start_shark_timer()
			sharkSpawnTimer.start(randi_range(5,15)+randf())
		pass
	pass # Replace with function body.

func player_ran_out_of_health():
	gameStarted = false
	
	fishTimer.stop()
	trashTimer.stop()
	startTimer.stop()
	gameTimer.stop()
	gameEndTimer.stop()
	finalCountdownTimer.stop()
	sharkSpawnTimer.stop()
	
	for fish in $FishContainer.get_children():
		if !fish.wasCollected:
			vanish_node_with_effect(fish)
		
	for trash in $TrashContainer.get_children():
		vanish_node_with_effect(trash)
	
	timeLabel.text =str(fontTimeLabel, "00:00") 
	$UI/Start.text = str(fontStartLabel, "NO HEALTH LEFT!")
	$UI/Start.visible = true
	currentWave = 6
	await get_tree().create_timer(1.5).timeout
	
	finalScore.text = str("[wave amp=10.0 freq=5.0 connected=0][outline_size=20][font_size=100][center]", "Current score: \n", currentScore)
	$UI/UIFadeAnimation.play("fade_out_times_up")
	pass


func _on_go_to_next_round_timer_timeout() -> void:
	#restart_game()
	show_wave_label()
	pass # Replace with function body.


func _on_ui_fade_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out_score":
		show_wave_label()
		pass
	pass # Replace with function body.
