extends RichTextLabel

var move_speed := 50
var lifetime := 3.0

func _ready():
	modulate.a = 1.0 #transparency
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta):
	position.y -= move_speed * delta
	modulate.a = lerp(modulate.a, 0.0, delta * 0.5) #modulates the fade
