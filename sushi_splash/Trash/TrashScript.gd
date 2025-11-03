extends TrashClass

var move_speed: float = 50.0
var direction := Vector2.ZERO
var animationPlayer
var boatRef:Node2D


func _ready() -> void:
	get_node("AnimationPlayer").play("bobbing")
	
	boatRef = get_parent().get_parent().get_node("Boat")
	
	move_speed *= randf_range(1,1.3)
	if global_position.x < 960:
		direction = Vector2.RIGHT
		$Container/Container/Sprite2D.scale.x *= 1
	else:
		direction = Vector2.LEFT
		$Container/Container/Sprite2D.scale.x *= -1
	
	move_speed*= randf_range(1.0,2.0)
	
	$Container/Container/Sprite2D.visible = true
	pass

func _process(delta: float) -> void:
	
	if !goTowardsBoat:
		global_position += direction * move_speed * delta
	else:
		global_position = lerp(global_position,boatRef.global_position+Vector2(0,100),0.04)
		pass
	pass

func collect():
	var game = get_tree().root.get_node("Game")
	game.trash_collected(self)
	$TrashPickup.play("trash_pickup")
	pass

#func _on_area_entered(area: Area2D) -> void:
	#var player = area.get_parent()
	#if area.get_parent().is_in_group("Player"):
		#if player.global_position.y < global_position.y - 50:
			#collect()
	#pass # Replace with function body.

func trash_setup(textureName: String) -> void:
	trashName = textureName
	match textureName:
		"Barrel":
			score = 200 #Nastavi pol
			_set_texture("oilbarrel") #Nastavi pol
			$Container/Container/Sprite2D.scale = Vector2(0.5,0.5)
			$Container/Container/Sprite2D.position = Vector2(0,-50)/2
		#"Plastic":
			#score = 500 #Nastavi pol
			#_set_texture("OldShoes") #Nastavi pol
		"Old_Shoe":
			score = 80 #Nastavi pol
			_set_texture("OldShoes") #Nastavi pol
			$Container/Container/Sprite2D.scale = Vector2(0.35,0.35)
			$Container/Container/Sprite2D.position = Vector2(0,-67)/2
		"Seaweed":
			score = 50 #Nastavi pol
			_set_texture("Seaweed") #Nastavi pol
			$Container/Container/Sprite2D.scale = Vector2(0.59,0.59)
			$Container/Container/Sprite2D.position = Vector2(0,-65)/2
		"Plastic":
			score = 150
			_set_texture("Plastic")  # Default zadeva
			$Container/Container/Sprite2D.scale = Vector2(0.3,0.3)
			$Container/Container/Sprite2D.position = Vector2(0,-62)/2
			
		_:
			score = 100
			_set_texture("OldShoes")  # Default zadeva
			$Container/Container/Sprite2D.scale = Vector2(0.4,0.4)
			$Container/Container/Sprite2D.position = Vector2(0,-67)

func _set_texture(texture_name: String):
	var path = "res://Trash/TrashTextures/%s.png" % texture_name
	var texture = load(path)
	if texture:
		$Container/Container/Sprite2D.texture = texture
pass


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	print("trash exited the screen")
	pass # Replace with function body.


func _on_trash_pickup_animation_finished(_anim_name: StringName) -> void:
	queue_free()
	pass # Replace with function body.

var goTowardsBoat:bool = false
func go_towards_boat():
	goTowardsBoat = true
	z_index = 0
	pass
