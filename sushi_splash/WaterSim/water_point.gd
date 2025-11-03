extends Node2D

# configuration
var spring_strength := 100.0
var damping := 4.0

# runtime variables
var velocity := 0.0
var start_position := Vector2.ZERO

var leftNeighbours:Array
var rightNeighbours

func _ready():
	start_position = position

func update_water(delta):
	# calculate the spring force
	var displacement := position.y - start_position.y
	var spring_force := -spring_strength * displacement
	var damping_force := -damping * velocity

	# net force and acceleration
	var force := spring_force + damping_force
	var acceleration := force

	# update velocity and position
	velocity += acceleration * delta
	position.y += velocity * delta

var velToApply:float = 0
func check_neighbours(leftN:Array,rightN:Array):
	var damp = 0.02
	for n in leftN:
		velToApply+=n.velocity*damp
	for n in rightN:
		velToApply+=n.velocity*damp
	pass

func apply_neighbour_vel():
	velocity+=velToApply
	velToApply = 0
	pass

func setup_area_size(areaSize:Vector2):
	var rect:RectangleShape2D = RectangleShape2D.new()
	rect.set_size(areaSize)
	$DetectionArea/CollisionShape2D.shape = rect
	
	$SplashParticles.emission_rect_extents = Vector2(areaSize.x,1)
	pass


func _on_detection_area_mouse_entered() -> void:
	velocity+=800
	pass # Replace with function body.


func _on_detection_area_area_entered(area: Area2D) -> void:
	#print(area.get_parent().is_in_group("Fish"))
	if area.get_parent().is_in_group("Boat"):
		velocity-=300-randi()%300
		$SplashParticles.emitting = true
		$ParticleTimer.stop()
		$ParticleTimer.start()
	if area.get_parent().get_parent().is_in_group("Fish"):
		var fish = area.get_parent().get_parent()
		if area.get_parent().get_parent().is_ascending():
			velocity+=400+randi()%300
			fish.get_node("AnimationPlayer").play("Despawn")
			pass
		else:
			velocity-=600-randi()%300
			pass
		$SplashParticles.emitting = true
		$ParticleTimer.stop()
		$ParticleTimer.start()
	pass # Replace with function body.


func apply_force(f):
	velocity+=f
	$SplashParticles.emitting = true
	$ParticleTimer.stop()
	$ParticleTimer.start()
	pass

func _on_particle_timer_timeout() -> void:
	$SplashParticles.emitting = false
	pass # Replace with function body.
