extends Camera2D

@export var player_path: NodePath
@export var max_offset: float = 200.0

var current_offset: Vector2 = Vector2.ZERO
var screen_center: Vector2 = Vector2(1920, 1080) / 2 

func _process(delta: float) -> void:
	var player_node: Node2D = get_node_or_null(player_path)
	if player_node == null:
		return

	var to_player: Vector2 = player_node.global_position - screen_center

	var target_offset: Vector2 = Vector2(
		clamp(to_player.x, -max_offset, max_offset),
		clamp(to_player.y, -max_offset, max_offset)
	)

	current_offset = current_offset.lerp(target_offset, delta * 1.5)
	offset = current_offset
