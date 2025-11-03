extends Label

var move_speed := 50
var lifetime := 1.0

func _ready():
	modulate.a = 1.0
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta):
	position.y -= move_speed * delta  # Move up
	modulate.a = lerp(modulate.a, 0.0, delta * 2)  # Fade out
